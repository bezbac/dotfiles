// ==UserScript==
// @name        diff button
// @match       https://github.com/*/*/pull/*
// @run-at document-start
// ==/UserScript==

(function () {
  "use strict";

  function insertDiffButton() {
    const actionsContainer = document.querySelector(
      '[data-component="PH_Actions"]',
    );

    if (!actionsContainer || actionsContainer.querySelector(".diff-button")) {
      return;
    }

    const button = document.createElement("a");
    button.href = window.location.href + ".diff";
    button.className = "btn btn-sm mr-1 diff-button";
    button.textContent = "Diff";
    button.title = "View raw diff";

    actionsContainer.insertBefore(button, actionsContainer.firstChild);
  }

  // Try inserting button on load
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", insertDiffButton);
  } else {
    insertDiffButton();
  }

  // Handle dynamic content changes
  new MutationObserver(() => insertDiffButton()).observe(document.body, {
    childList: true,
    subtree: true,
    // Only watch for added nodes, ignore attributes and character data
    attributes: false,
    characterData: false,
    attributeOldValue: false,
    characterDataOldValue: false,
  });
})();
