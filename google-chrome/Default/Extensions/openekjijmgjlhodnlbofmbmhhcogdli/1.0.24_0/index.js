const browserApi = BrowserApiFactory.getInstance();
let randomThreadId;
let lastFirstQuestion;

function boot(){
  injectChatHistoryModal();
  observeEndOfAnAnswer();
}

function observeEndOfAnAnswer(){
  const MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
  const observer = new MutationObserver(function(mutations) {
      mutations.forEach((mutation) => {
          for(let i = 0; i < mutation.addedNodes.length; i++) {
            const node = mutation.addedNodes[i];
            if(detectTryAgainButton(node) || detectSendButton(node)){
              const collectedThread = scrapeThread();
              saveCollectedThread(collectedThread);
            }
          }
      });
  });
  
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });
}

function detectTryAgainButton(node){
  if(node.innerText){
    return node.innerText.toUpperCase() == "TRY AGAIN" || node.innerText.toUpperCase() == "REGENERATE RESPONSE";
  }

  return false;
}

function detectVoteButtons(node){
  return node.childNodes && node.childNodes.length == 2 && node.childNodes[0].nodeName == "BUTTON" && node.childNodes[0].nodeName == "BUTTON"
}

function detectSendButton(node){
  if(node && node.nodeName.toUpperCase() == "SVG" && node.classList){
    return Array.from(node.classList).indexOf("rotate-90") > -1;
  }

  return false;
}

function injectChatHistoryButton() {
  const resetThreadLink = findResetThreadLink();
  if(resetThreadLink) {
    onResetThreadLinkClick(resetThreadLink);
  }

  const chatHistoryElement = document.createElement("span");
  chatHistoryElement.innerHTML = getChatHistoryButtonHtml();
  chatHistoryElement.id = "chatGPTHistoryBtn";

  chatHistoryElement.onclick = async() =>{
    displayModalContent();
  }
  
  injectChatHistoryButtonContainer();
  document.querySelector(".chatGPTHistoryButtonContainer").appendChild(chatHistoryElement);
}

async function displayModalContent(){
  const data = await popupToBackground("get-threads") || {};
  const threads = Object.values(data) || [];
  populateThreadHistory(threads);
  setupSearch(threads);
}

function populateThreadHistory(threads){
  const html = constructChatHistoryHtml(threads) || '<iframe class="demo" width="100%" height="500px" src="https://www.youtube.com/embed/B1lhcUoqxXo" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>';
  const modalSavedThreads = document.querySelector(".chatGPTHistoryModal .savedThreads");
  modalSavedThreads.innerHTML = html;
  document.querySelector(".chatGPTHistoryDisplayThreadCount").innerHTML = threads.length;
  document.querySelector(".chatGPTHistoryModal").classList.remove("hidden");
  setupActionButtons();
}

function injectChatHistoryButtonContainer() {
  const chatHistoryButtonContainer = document.createElement("div");
  chatHistoryButtonContainer.className = "chatGPTHistoryButtonContainer"
  document.body.appendChild(chatHistoryButtonContainer);
}

function injectChatHistoryModal() {
  const modalElement = document.createElement("div");
  modalElement.innerHTML = `<div class="chatGPTHistoryModal hidden"><div class="container"><div class="body"><div class="chatGPTHistoryModalHeader"><p class="logoImgAndText"><a href="https://savegpt.com" target="_blank"><img src="https://savegpt.com/images/logo.png"/><span>SaveGPT</a></span></p><input class="searchThreads" type="text" placeholder="🔍 Search threads ..."/></div><p class="banner">Displaying <span class="chatGPTHistoryDisplayThreadCount">0</span> saved threads.<a target="_blank" class="twitterLink" href="https://twitter.com/piyush_santwani" >Follow on <img src="${browserApi.runtime.getURL("/icons/twitter.png")}" /></a > </p><div class="savedThreads"></div></div></div></div>`;

  document.body.appendChild(modalElement);
  
  const modal = document.querySelector(".chatGPTHistoryModal");
  const container = modal.querySelector(".chatGPTHistoryModal .container");
  const searchInput = document.querySelector(".chatGPTHistoryModalHeader .searchThreads");

  modal.addEventListener("click", function (e) {
    if (e.target !== modal && e.target !== container) return;     
    if(searchInput){
      searchInput.value = "";
    }
    modal.classList.add("hidden");
  });

  injectChatHistoryButton();
}

function constructChatHistoryHtml(threads) {
  if(!threads){
    return '';
  }

  threads.sort((a,b) => {
    return b.updatedAt - a.updatedAt;
  });

  let html = ``;
  for(let i = 0; i < threads.length; i++){
    const threadId = threads[i].threadId;
    html += `<div class="chatGPTHistoryThreadRef_${threadId}">`
    html += `<div class="chatGPTHistoryThreadHeader thread_${threadId}">`;
    if(threads[i].updatedAt){
      html += `<div class="chatGPTHistoryThreadTime"><p>${formatDateAndTime(threads[i].updatedAt)}</p></div>`;
    }
    html += `<span class="chatGPTHistoryThreadActions"><span threadId="${threads[i].threadId}" class="chatGPTHistoryDeleteThread"><img src="${browserApi.runtime.getURL("/icons/delete.png")}" /></span><span class="chatGPTHistoryExportToPDF"><img src="${browserApi.runtime.getURL("/icons/pdf.png")}" /></span><span class="chatGPTHistoryExportToImage"><img src="${browserApi.runtime.getURL("/icons/image.png")}" /></span></span>`;
    html += `</div>`;

    const threadsArr = threads[i].thread;
    html += `<div class="chatGPTHistoryQNA thread_${threadId}">`;
    for(let j = 0; j < threadsArr.length; j++){
      const threadHtml = threadsArr[j].value;  
      if(threadHtml){
        html += threadHtml;
      }
    }
    html += `</div>`;
    html += `</div>`;
  }

  return html;
}

function setupSearch(threads) {
  if(!(threads && threads.length)){
    return;
  }

  threads.map((threadObj) => {
    const threadList = threadObj.thread;
    if(!(threadList && threadList.length)){
      return threadObj;
    };

    let threadHtml = '<div class="extractText">';
    threadList.forEach((threadItem) => {
      threadHtml += threadItem.value || '';
    });
    threadHtml += '</div>'

    threadObj['searchableText'] = extractTextContent(threadHtml);
    return threadObj;
  });

  const searchInput = document.querySelector(".chatGPTHistoryModalHeader .searchThreads");
  let prevLength = 0;

  searchInput.addEventListener("input", function (event) {
    const searchText = searchInput.value.toUpperCase();
    const searchTextLength = searchText.length;

    if (searchTextLength <= 2) {
      populateThreadHistory(threads);
      return;
    }

    if (searchTextLength >= 3) {
      const filteredThreads = threads.filter((savedThread) => {
        const searchableText = savedThread.searchableText ? savedThread.searchableText.toUpperCase() : "";
        return searchableText.indexOf(searchText) > -1;
      });

      populateThreadHistory(filteredThreads);
    }
  });
}

function extractTextContent(html){
  const doc = new DOMParser().parseFromString(html, 'text/html');
  return doc && doc.querySelector(".extractText") ? doc.querySelector(".extractText").innerText : '';
}

const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
function formatDateAndTime(time) {
  const dt = new Date(time);
  return `${days[dt.getDay()]}, 
    ${padL(dt.getMonth()+1)}/${
    padL(dt.getDate())}/${
    dt.getFullYear()} ${
    padL(dt.getHours())}:${
    padL(dt.getMinutes())}`;
}

const padL = (nr, len = 2, chr = `0`) => `${nr}`.padStart(2, chr);

function findResetThreadLink() {
  const links = document.querySelectorAll('a');
  let resetThreadLink;

  for (let i=0, l=links.length; i<l; i++) {
    if (links[i].innerText == "Reset Thread" || links[i].innerText == "New Thread" || links[i].innerText == "New Chat"){
      resetThreadLink = links[i];
      break;
    }
  }

  return resetThreadLink;
}

function onResetThreadLinkClick(link){
  if(!link){
    return;
  }

  link.onclick = function(){
    lastFirstQuestion = null;
  }
}

function getChatHistoryButtonHtml() {
  return `<a  class="flex py-3 px-3 items-center gap-4 rounded-md cursor-pointer text-sm"><svg stroke="currentColor" fill="none" stroke-width="2" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round" class="w-4 h-4" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg"><polyline points="1 4 1 10 7 10"></polyline><polyline points="23 20 23 14 17 14"></polyline><path d="M20.49 9A9 9 0 0 0 5.64 5.64L1 10m22 4l-4.64 4.36A9 9 0 0 1 3.51 15"></path></svg>Chat History</a>`;
}

function saveCollectedThreadBeforeReload() {
  window.onbeforeunload = (event) => {
    saveCollectedThread();
  };
}

function scrapeThread(){
  const threadContainer = document.querySelector(
    "#__next main div:nth-of-type(1) div:nth-of-type(1) div:nth-of-type(1) div:nth-of-type(1)"
  );

  const conversationData = {
    items: [],
    threadId: null
  };

  let counter = 0;
  for (const node of threadContainer.children) {
    const markdownContent = node.querySelector(".markdown"); // TODO: Check if this errors often.

    if(counter == 0) {
      if(node.textContent != lastFirstQuestion) {
        lastFirstQuestion = node.textContent;
        randomThreadId = generateRandomNumber();
      }

      conversationData.threadId = randomThreadId;
    }

    if ([...node.classList].includes("dark:bg-gray-800")) {
      conversationData.items.push({
        sender: "self",
        value: `<div class="chatGPTHistoryQuestion">${node.outerHTML}</div>`
      });
    } else if ([...node.classList].includes("bg-gray-50")) {
      conversationData.items.push({
        sender: "chatGPT",
        value: `<div class="chatGPTHistoryAnswer">${markdownContent.outerHTML}</div>`
      });
    }

    counter++;
  }

  return conversationData;
}

async function saveCollectedThread(collectedThread){
  if(collectedThread){
    await popupToBackground("save-thread", collectedThread);
  }
}

function setupActionButtons(){
  const deleteThreadTooltip = new Tooltip();
  const deleteThreadElements = document.querySelectorAll('.chatGPTHistoryDeleteThread');
  for(let i = 0; i < deleteThreadElements.length; i++){
    const deleteThreadElement = deleteThreadElements[i];
    deleteThreadTooltip.show(deleteThreadElement, "");
    deleteThreadTooltip.hide();

    deleteThreadElement.addEventListener('mouseenter', () => {
      deleteThreadTooltip.show(deleteThreadElement, 'Delete thread', {
            placement: "top",
        });
    });

    deleteThreadElement.addEventListener('mouseleave', () => {
      deleteThreadTooltip.hide();
    });

    deleteThreadElement.onclick = async() => {
        deleteThreadTooltip.destroy();
        const threadId = deleteThreadElement.getAttribute("threadId");
        await popupToBackground("delete-thread", threadId);
        deleteThread(threadId);
    }
  }
}

async function deleteThread(threadId){
  const threadRefElement = document.querySelector(`.chatGPTHistoryThreadRef_${threadId}`);
  if(threadRefElement){
    threadRefElement.remove();
  }

  const threadCountElement = document.querySelector(".chatGPTHistoryDisplayThreadCount");
  if(threadCountElement){
    threadCountElement.innerHTML = parseInt(threadCountElement.innerText) - 1;
  }

  const searchInput = document.querySelector(".chatGPTHistoryModalHeader .searchThreads");
  const searchInputValue = searchInput.value;
  searchInput.parentElement.innerHTML = searchInput.parentElement.innerHTML;

  const data = await popupToBackground("get-threads");
  const threads = Object.values(data) || [];
  setupSearch(threads);
  document.querySelector(".chatGPTHistoryModalHeader .searchThreads").value = searchInputValue
}


boot();