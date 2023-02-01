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

function popupToBackground(action, payload) {
	return new Promise((resolve, reject) => {
		BrowserApiFactory.getInstance().runtime.sendMessage(
			{
				action,
				payload,
			},
			async (response) => {
				let { err, data } = response;
				if (err && !err.customErrorCode) {
					return reject(err);
				}

				try {
					await errorManagement(err);
				} catch (err) {
					return resolve(data);
				}

				return resolve(data);
			}
		);
	});
}

function generateRandomNumber(){
	return Math.floor(Math.random() * 1000000000);
}