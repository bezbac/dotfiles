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
} from "https://deno.land/x/karabinerts@1.36.0/deno.ts";
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
  rule("Emoji Search").manipulators([
    map("spacebar", ["command", "control"]).to$(
      "open tuna://run/TunaEmoji.EmojiSearchCatalog.Emoji/Tuna.BasicActionsCatalog.Browse",
    ),
  ]),

  rule("Hyper Key (⌃⌥⇧⌘)").manipulators([
    // Switch back to previous application when pressing Caps Lock / Escape while in Tuna menu
    withCondition(ifApp("com.brnbw.Tuna"))([
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

    withCondition(ifApp("com.brnbw.Tuna").unless())([
      hyperKeyTrigger().toIfAlone({
        key_code: "escape",
      }),
    ]),

    withCondition(ifVar(HYPER_VAR, 1))(
      [
        map("o").to$(
          "open tuna://run/Tuna.ModesCatalog.Leader%20Mode/TunaCore.CommonActionsCatalog.Switch",
        ),
        map("slash").to$(
          "open tuna://run/TunaSystem.MenuItemsCatalog.Menu%20Items/Tuna.BasicActionsCatalog.Browse",
        ),

        // Vim-like navigation
        // The "optionalAny" is needed to allow the key to be held down for repeat
        // See: https://github.com/evan-liu/karabiner.ts/discussions/104
        map("h", "optionalAny").to({ key_code: "left_arrow" }),
        map("j", "optionalAny").to({ key_code: "down_arrow" }),
        map("k", "optionalAny").to({ key_code: "up_arrow" }),
        map("l", "optionalAny").to({ key_code: "right_arrow" }),
        map("w", "optionalAny").to({
          key_code: "right_arrow",
          modifiers: ["option"],
        }),
        map("b", "optionalAny").to({
          key_code: "left_arrow",
          modifiers: ["option"],
        }),

        map("t").toVar(HYPER_VAR, "t"),

        // Improved window switching
        map("s").to({
          key_code: "grave_accent_and_tilde",
          modifiers: ["command"],
        }),
      ].map((x) => x.to(escape)),
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

const karabinerJsonPath = path.join(__dirname, "./karabiner.json")

const emptyConfig = {
  profiles: [
    {
      name: "Default",
      complex_modifications: {},
    },
  ],
};


await Deno.writeTextFile(karabinerJsonPath, JSON.stringify(emptyConfig));

writeToProfile(
  {
    name: "Default",
    karabinerJsonPath: karabinerJsonPath,
  },
  rules,
);
