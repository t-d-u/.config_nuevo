const apis = [
  "alarms",
  "bookmarks",
  "browserAction",
  "commands",
  "contextMenus",
  "cookies",
  "downloads",
  "events",
  "extension",
  "extensionTypes",
  "history",
  "i18n",
  "idle",
  "notifications",
  "pageAction",
  "runtime",
  "storage",
  "tabs",
  "webNavigation",
  "webRequest",
  "windows",
];

const BrowserApiFactory = (function () {
  function BrowserApi() {
    const _this = this;

    apis.forEach(function (api) {
      _this[api] = null;

      try {
        if (chrome[api]) {
          _this[api] = chrome[api];
        }
      } catch (e) {}

      try {
        if (window[api]) {
          _this[api] = window[api];
        }
      } catch (e) {}

      try {
        if (browser[api]) {
          _this[api] = browser[api];
        }
      } catch (e) {}
      try {
        _this.api = browser.extension[api];
      } catch (e) {}
    });

    try {
      if (browser && browser.runtime) {
        this.runtime = browser.runtime;
      }
    } catch (e) {}

    try {
      if (browser && browser.browserAction) {
        this.browserAction = browser.browserAction;
      }
    } catch (e) {}
  }

  var browserApi;
  return {
    getInstance: function () {
      if (browserApi == null) {
        browserApi = new BrowserApi();
        browserApi.constructor = null;
      }
      return browserApi;
    },
  };
})();

const browserApi = BrowserApiFactory.getInstance();

browserApi.runtime.onInstalled.addListener(async (details) => {
  if (
    isVersionGreater(details.previousVersion, "1.0.20")
  ) {
    await oneTimeDataMassage();
  }
});

browserApi.runtime.onMessage.addListener(function (
  request,
  sender,
  sendResponse
) {
  if (!sendResponse) {
    return;
  }
  switch (request.action) {
    case "save-thread":
      saveThreadCb(request.payload, (response) => {
        sendResponse(response);
      });
      break;
    case "get-threads":
      getThreadsCb((response) => {
        sendResponse(response);
      });
      break;
    case "delete-thread":
      deleteThreadCb(request.payload, (response) => {
        sendResponse(response);
      });
      break;
    default:
      sendResponse({
        err: "Unknown operation",
        data: null,
      });
      break;
  }
  return true;
});

async function saveThreadCb(payload, cb) {
  cb(await saveThread(payload));
}

async function getThreadsCb(cb) {
  cb(await getAllLocallySavedThreads());
}

async function deleteThreadCb(payload, cb) {
  cb(await deleteThread(payload));
}

function saveThread(payload) {
  return new Promise(async (resolve, reject) => {
    if (!(payload && payload.items && payload.items.length)) {
      resolve({ err: null, data: "ok" });
    }

    const { err, data } = await getAllLocallySavedThreads();
    let threads = data || {};

    const newThread = payload.items;
    if (!(newThread && newThread.length)) {
      resolve({ err: null, data: "ok" });
    }

    const threadId = payload.threadId;
    const isNewThread = threads[threadId] ? false : true;

    threads[threadId] = {
      thread: newThread,
      updatedAt: new Date().getTime(),
      threadId,
    };

    if (isNewThread) {
      threads[threadId]["createdAt"] = new Date().getTime();
    }

    browserApi.storage.local.set(
      { chgSavedThreadsLocal: threads },
      function () {
        resolve({ err: null, data: "ok" });
      }
    );
  });
}

function getAllLocallySavedThreads() {
  return new Promise((resolve, reject) => {
    browserApi.storage.local.get(["chgSavedThreadsLocal"], function (result) {
      return resolve({ err: null, data: result.chgSavedThreadsLocal });
    });
  });
}

function deleteThread(threadId) {
  return new Promise(async (resolve, reject) => {
    if (!threadId) {
      return resolve({ err: null, data: "ok" });
    }

    const { err, data } = await getAllLocallySavedThreads();
    let threads = data || {};

    delete threads[threadId];

    browserApi.storage.local.set(
      { chgSavedThreadsLocal: threads },
      function () {
        return resolve({ err: null, data: "ok" });
      }
    );
  });
}

function oneTimeDataMassage() {
  return new Promise(async (resolve, reject) => {
    try {
      const { err, data } = await getAllLocallySavedThreads();
      let threadsObj = data || {};

      for (let threadId in threadsObj) {
        const threadObj = threadsObj[threadId];
        threadsObj[threadId] = { ...threadObj, threadId };
      }

      browserApi.storage.local.set(
        { chgSavedThreadsLocal: threadsObj },
        function () {
          return resolve({ err: null, data: true });
        }
      );
    } catch (error) {
      return resolve({ err, data: false });
    }
  });
}

function saveThreadsRemote() {
  return new Promise(async (resolve, reject) => {
    ({ err, data } = await get({ key1: "chgConfig" }));
    const chgConfig = data || {};
    const userId = chgConfig.userId || uuidv4();
    const lastSync = parseInt(chgConfig.lastSync) || 1;

    ({ err, data } = await getAllLocallySavedThreads());
    let threadsObj = data || {};

    let payload = [];
    let lastUpdatedAt = lastSync;

    for (let threadId in threadsObj) {
      const threadObj = threadsObj[threadId];
      threadObj.userId = userId;
      threadObj.id = threadObj.userId + "_" + threadObj.threadId;
      if (threadObj.updatedAt > lastSync) {
        threadObj.thread = JSON.stringify(threadObj.thread);
        payload.push(threadObj);
        lastUpdatedAt = threadObj.updatedAt;
      }
    }

    const payloadArr = splitArrayBySize(payload, 1000);

    if (payloadArr.length) {
      for(let i = 0; i < payloadArr.length; i++){
        const payloadItem = payloadArr[i];
        if(!payloadItem.length){
          continue;
        }

        const response = await fetch("https://share.savegpt.com/chats", {
          method: "POST",
          headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ payload: payloadItem }),
          mode: 'no-cors',
          json: true,
        });

        const result = await response.status;

        if (result == 200) {
          await set({
            key1: "chgConfig",
            key2: "lastSync",
            value2: lastUpdatedAt,
          });
        }
      }
    }

    if (!chgConfig.userId) {
      await set({ key1: "chgConfig", key2: "userId", value2: userId });
    }

    return resolve({ err: null, data: true });
  });
}

function isVersionGreater(a, b) {
  return a.localeCompare(b, undefined, { numeric: true }) === 1;
}

function uuidv4() {
  return ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, (c) =>
    (
      c ^
      (crypto.getRandomValues(new Uint8Array(1))[0] & (15 >> (c / 4)))
    ).toString(16)
  );
}

function get({ key1, key2 }) {
  return new Promise(async (resolve, reject) => {
    browserApi.storage.local.get([key1], function (result) {
      if (!key2) {
        return resolve({ err: null, data: result[key1] });
      }

      if (result[key1]) {
        return resolve({ err: null, data: result[key1][key2] });
      } else {
        return resolve({ err: null, data: null });
      }
    });
  });
}

function set({ key1, value1, key2, value2 }) {
  return new Promise(async (resolve, reject) => {
    let payloadToSave = {};
    const savedAt = new Date().getTime();

    if (key1 && value1) {
      payloadToSave[key1] = { ...value1, savedAt };

      browserApi.storage.local.set(payloadToSave, function () {
        return resolve({ err: null, data: true });
      });
    } else if (key1 && key2 && value2) {
      let item = {};
      item[key2] = isJson(value2) ? { ...value2, savedAt } : value2;
      const { err, data: savedData } = await get({ key1 });

      const payloadValue = savedData ? { ...savedData, ...item } : item;

      let payloadToSave = {};
      payloadToSave[key1] = { ...payloadValue, savedAt };

      browserApi.storage.local.set(payloadToSave, function () {
        resolve({ err: null, data: true });
      });
    }
  });
}

function isJson(item) {
  item = typeof item !== "string" ? JSON.stringify(item) : item;

  try {
    item = JSON.parse(item);
  } catch (e) {
    return false;
  }

  if (typeof item === "object" && item !== null) {
    return true;
  }

  return false;
}

function splitArrayBySize(arr, thresholdSize) {
  var newArrays = [];
  var currentArray = [];
  var currentSize = 0;
  for (var i = 0; i < arr.length; i++) {
      var itemSize = (JSON.stringify(arr[i]).length / 1000); // convert item size to KB
      if (currentSize + itemSize > thresholdSize) {
          newArrays.push(currentArray);
          currentArray = [];
          currentSize = 0;
      }
      currentArray.push(arr[i]);
      currentSize += itemSize;
  }
  newArrays.push(currentArray);
  return newArrays;
}

saveThreadsRemote();