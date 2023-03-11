// ==UserScript==
// @name Reddit redirect to old.reddit.com
// @match *://www.reddit.com/*
// @grant none
// @run-at document-start
// ==/UserScript==

(function () {
  window.location.href = 'https://old.reddit.com' + location.pathname;
})();