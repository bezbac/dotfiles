// ==UserScript==
// @name        reddit
// @match       *://www.reddit.com/*
// @run-at document-start
// ==/UserScript==

(function () {
  window.location.href = "https://old.reddit.com" + location.pathname;
})();
