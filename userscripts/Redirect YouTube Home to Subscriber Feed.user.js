// ==UserScript==
// @name        Redirect YouTube Home to Subscriber Feed
// @description This is your new file, start writing code
// @match       https://www.youtube.com/
// ==/UserScript==

(function () {
  window.location.href = "https://www.youtube.com/feed/subscriptions";
})();
