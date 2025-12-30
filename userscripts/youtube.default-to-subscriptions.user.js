// ==UserScript==
// @name        default to subscriptions
// @match       *://www.youtube.com/*
// ==/UserScript==

(function () {
  // Redirect home page to subscription feed
  if (window.location.href === "https://www.youtube.com/") {
    window.location.href = "https://www.youtube.com/feed/subscriptions";
  }
})();
