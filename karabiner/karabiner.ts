#!/usr/bin/env -S deno run --allow-read --allow-write

// Check https://github.com/evan-liu/karabiner.ts for documentation

import {
  rule,
  toUnsetVar,
  map,
  withCondition,
  ifVar,
  writeToProfile,
} from "https://deno.land/x/karabinerts@1.31.0/deno.ts";
import * as path from "https://deno.land/std@0.224.0/path/mod.ts";

const __dirname = new URL(".", import.meta.url).pathname;

const HYPER_VAR = "hyper";

const escape = [toUnsetVar("leader")];

const rules = [
  rule("Clipboard History").manipulators([
    map("v", ["command", "shift"]).to$(
      "open raycast://extensions/raycast/clipboard-history/clipboard-history"
    ),
  ]),

  rule("Hyper Key (⌃⌥⇧⌘)").manipulators([
    map("caps_lock", "", "any")
      .toVar(HYPER_VAR, 1)
      .toAfterKeyUp({
        set_variable: {
          name: HYPER_VAR,
          value: 0,
        },
      })
      .toIfAlone({
        key_code: "escape",
      }),

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
        map("h").to({ key_code: "left_arrow" }),
        map("j").to({ key_code: "down_arrow" }),
        map("k").to({ key_code: "up_arrow" }),
        map("l").to({ key_code: "right_arrow" }),
        map("w").to({ key_code: "right_arrow", modifiers: ["option"] }),
        map("b").to({ key_code: "left_arrow", modifiers: ["option"] }),

        map("t").toVar(HYPER_VAR, "t"),

        // Improved window switching
        map("s").to({
          key_code: "grave_accent_and_tilde",
          modifiers: ["command"],
        }),
      ].map((x) => x.to(escape))
    ),

    // Improved tab switching
    withCondition(ifVar(HYPER_VAR, "t"))(
      [
        map("h").to({ key_code: "tab", modifiers: ["left_control", "shift"] }),
        map("l").to({ key_code: "tab", modifiers: ["left_control"] }),
      ].map((x) => x.to(escape))
    ),
  ]),
];

writeToProfile(
  {
    name: "Default",
    karabinerJsonPath: path.join(__dirname, "./karabiner.json"),
  },
  rules
);
