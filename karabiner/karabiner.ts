#!/usr/bin/env -S deno run --allow-read --allow-write

// Check https://github.com/evan-liu/karabiner.ts for documentation

import {
  rule,
  toUnsetVar,
  map,
  withCondition,
  ifVar,
  writeToProfile,
  ifApp,
} from "https://deno.land/x/karabinerts@1.31.0/deno.ts";
import * as path from "https://deno.land/std@0.224.0/path/mod.ts";

const __dirname = new URL(".", import.meta.url).pathname;

const HYPER_VAR = "hyper";

const escape = [toUnsetVar("leader")];

function hyperKeyTrigger() {
  return map("caps_lock", "", "any")
    .toVar(HYPER_VAR, 1)
    .toAfterKeyUp({
      set_variable: {
        name: HYPER_VAR,
        value: 0,
      },
    });
}

const rules = [
  rule("Clipboard History").manipulators([
    map("v", ["command", "shift"]).to$(
      "open raycast://extensions/raycast/clipboard-history/clipboard-history"
    ),
  ]),

  rule("Hyper Key (⌃⌥⇧⌘)").manipulators([
    // Switch back to previous application when pressing Caps Lock / Escape while in Leader Key app
    withCondition(ifApp("com.brnbw.Leader-Key"))([
      hyperKeyTrigger().toIfAlone([
        {
          key_code: "escape",
        },
        {
          software_function: {
            open_application: { frontmost_application_history_index: 1 },
          },
        },
      ]),

      map("escape").to([
        {
          key_code: "escape",
        },
        {
          software_function: {
            open_application: { frontmost_application_history_index: 1 },
          },
        },
      ]),
    ]),

    withCondition(ifApp("com.brnbw.Leader-Key").unless())([
      hyperKeyTrigger().toIfAlone({
        key_code: "escape",
      }),
    ]),

    withCondition(ifVar(HYPER_VAR, 1))(
      [
        map("o").to$("open leaderkey://"),
        map("slash").to$(
          "open raycast://extensions/raycast/navigation/search-menu-items"
        ),
        map("slash").to$(
          "open raycast://extensions/raycast/navigation/switch-windows"
        ),

        // Vim-like navigation
        // The "optionalAny" is needed to allow the key to be held down for repeat
        // See: https://github.com/evan-liu/karabiner.ts/discussions/104
        map("h", "optionalAny").to({ key_code: "left_arrow" }),
        map("j", "optionalAny").to({ key_code: "down_arrow" }),
        map("k", "optionalAny").to({ key_code: "up_arrow" }),
        map("l", "optionalAny").to({ key_code: "right_arrow" }),
        map("w", "optionalAny").to({ key_code: "right_arrow", modifiers: ["option"] }),
        map("b", "optionalAny").to({ key_code: "left_arrow", modifiers: ["option"] }),

        map("t").toVar(HYPER_VAR, "t"),

        // Improved window switching
        map("s").to({
          key_code: "grave_accent_and_tilde",
          modifiers: ["command"],
        }),
      ].map((x) => x.to(escape))
    ),

    // Improved tab switching
    // Note: Zellij is using Ctrl+Tab for pane switching, so this mapping should be disabled when WezTerm is focused
    withCondition(ifApp("com.github.wez.wezterm").unless())([
      map("h", ["control"]).to({
        key_code: "tab",
        modifiers: ["left_control", "shift"],
      }),
      map("l", ["control"]).to({
        key_code: "tab",
        modifiers: ["left_control"],
      }),
    ]),
  ]),
];

writeToProfile(
  {
    name: "Default",
    karabinerJsonPath: path.join(__dirname, "./karabiner.json"),
  },
  rules
);
