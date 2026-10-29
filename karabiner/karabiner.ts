#!/usr/bin/env -S deno run --allow-read --allow-write

// Check https://github.com/evan-liu/karabiner.ts for documentation

import {
  ifApp,
  ifVar,
  map,
  rule,
  toUnsetVar,
  withCondition,
  writeToProfile,
} from "https://deno.land/x/karabinerts@1.36.0/deno.ts";
import * as path from "https://deno.land/std@0.224.0/path/mod.ts";

const __dirname = new URL(".", import.meta.url).pathname;

const HYPER_VAR = "hyper";

const escape = [
  toUnsetVar("leader"),
  { set_notification_message: { id: "leader", text: "" } },
];

type LeaderAction =
  & {
    key: Parameters<typeof map>[0];
    label: string;
    shift?: boolean;
  }
  & (
    | { menu: string; command?: never }
    | { menu?: never; command: string }
  );

const leaderMenus: { id: string; label: string; actions: LeaderAction[] }[] = [
  {
    id: "root",
    label: "Leader",
    actions: [
      {
        key: "x",
        label: "WezTerm",
        command: "open -a '/Applications/WezTerm.app'",
      },
      {
        key: "b",
        label: "Safari",
        command: "open -a '/Applications/Safari.app'",
      },
      {
        key: "v",
        label: "VS Code",
        command: "open -a '/Applications/Visual Studio Code.app'",
      },
      {
        key: "f",
        label: "Finder",
        command: "open -a '/System/Library/CoreServices/Finder.app'",
      },
      {
        key: "s",
        label: "Spotify",
        command: "open -a '/Applications/Spotify.app'",
      },
      {
        key: "m",
        label: "Beeper",
        command: "open -a '/Applications/Beeper Desktop.app'",
      },
      {
        key: "c",
        label: "Calendar",
        command: "open -a '/System/Applications/Calendar.app'",
      },
      {
        key: "i",
        label: "Linear",
        command: "open -a '/Applications/Linear.app'",
      },
      {
        key: "d",
        label: "Figma",
        command: "open -a '/Applications/Figma.app'",
      },
      {
        key: "t",
        label: "Slack",
        command: "open -a '/Applications/Slack.app'",
      },
      {
        key: "o",
        label: "Bookmarks",
        command: "open 'raycast://extensions/raycast/browser-bookmarks/index'",
      },
      { key: "w", label: "Aerospace →", menu: "aerospace" },
    ],
  },
  {
    id: "aerospace",
    label: "Leader › Aerospace",
    actions: [
      {
        key: "m",
        shift: true,
        label: "maximize",
        command: "/opt/homebrew/bin/aerospace fullscreen",
      },
      {
        key: "f",
        shift: true,
        label: "fullscreen",
        command: "/opt/homebrew/bin/aerospace macos-native-fullscreen",
      },
      {
        key: "period",
        label: "flatten-workspace-tree",
        command: "/opt/homebrew/bin/aerospace flatten-workspace-tree",
      },
      {
        key: "n",
        label: "assign workspace to next display",
        command:
          "/opt/homebrew/bin/aerospace move-workspace-to-monitor next --wrap-around",
      },
      {
        key: "f",
        label: "toggle floating",
        command: "/opt/homebrew/bin/aerospace layout floating tiling",
      },
      { key: "j", label: "join-with →", menu: "join" },
      { key: "l", label: "layout →", menu: "layout" },
      { key: "m", label: "move →", menu: "move" },
      {
        key: "r",
        shift: true,
        label: "reload-config",
        command: "/opt/homebrew/bin/aerospace reload-config",
      },
      {
        key: "s",
        label: "mode resize",
        command: "/opt/homebrew/bin/aerospace mode resize",
      },
      {
        key: "c",
        label: "center",
        command: "open 'raycast://extensions/raycast/window-management/center'",
      },
    ],
  },
  {
    id: "join",
    label: "Leader › Aerospace › join-with",
    actions: [
      {
        key: "h",
        label: "left",
        command: "/opt/homebrew/bin/aerospace join-with left",
      },
      {
        key: "j",
        label: "down",
        command: "/opt/homebrew/bin/aerospace join-with down",
      },
      {
        key: "k",
        label: "up",
        command: "/opt/homebrew/bin/aerospace join-with up",
      },
      {
        key: "l",
        label: "right",
        command: "/opt/homebrew/bin/aerospace join-with right",
      },
    ],
  },
  {
    id: "layout",
    label: "Leader › Aerospace › layout",
    actions: [
      {
        key: "a",
        label: "accordion",
        command:
          "/opt/homebrew/bin/aerospace layout accordion horizontal vertical",
      },
      {
        key: "t",
        label: "tiles",
        command: "/opt/homebrew/bin/aerospace layout tiles vertical horizontal",
      },
    ],
  },
  {
    id: "move",
    label: "Leader › Aerospace › move",
    actions: [
      {
        key: "h",
        label: "left",
        command: "/opt/homebrew/bin/aerospace move left",
      },
      {
        key: "j",
        label: "down",
        command: "/opt/homebrew/bin/aerospace move down",
      },
      { key: "k", label: "up", command: "/opt/homebrew/bin/aerospace move up" },
      {
        key: "l",
        label: "right",
        command: "/opt/homebrew/bin/aerospace move right",
      },
    ],
  },
];

function enterLeaderMenu(id: string) {
  const menu = leaderMenus.find((menu) => menu.id === id);
  if (!menu) throw new Error(`Unknown leader menu: ${id}`);

  return [
    { set_variable: { name: "leader", value: id } },
    {
      set_notification_message: {
        id: "leader",
        text: `${menu.label}\n${
          menu.actions.map((action) => {
            const key = action.key === "period" ? "." : String(action.key);
            return `${action.shift ? key.toUpperCase() : key}  ${action.label}`;
          }).join("\n")
        }\nesc  cancel`,
      },
    },
  ];
}

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
  // Leader rules precede Hyper bindings so menus also work with Caps Lock held.
  rule("Leader: cancel").manipulators(
    withCondition(ifVar("leader", 0).unless())([
      map("escape", "optionalAny").to(escape),
      map("caps_lock", "", "any").to(escape).toAfterKeyUp({
        set_variable: { name: HYPER_VAR, value: 0 },
      }),
    ]),
  ),
  ...leaderMenus.map((menu) =>
    rule(menu.label).manipulators(
      withCondition(ifVar("leader", menu.id))(
        menu.actions.map((action) => {
          const binding = map(action.key, action.shift ? "shift" : "");
          if (action.menu !== undefined) {
            return binding.to(enterLeaderMenu(action.menu));
          }
          return binding.to([
            ...escape,
            { shell_command: action.command, repeat: false },
          ]);
        }),
      ),
    )
  ),
  rule("Emoji Search").manipulators([
    map("spacebar", ["command", "control"]).to$(
      "open raycast-x://extensions/raycast/emoji-symbols/search-emoji-symbols",
    ),
  ]),

  rule("Hyper Key (⌃⌥⇧⌘)").manipulators([
    // Switch back to previous application when pressing Caps Lock / Escape while in raycast menu
    withCondition(ifApp("com.raycast-x.macos"))([
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

    withCondition(ifApp("com.raycast-x.macos").unless())([
      hyperKeyTrigger().toIfAlone({
        key_code: "escape",
      }),
    ]),

    withCondition(ifVar(HYPER_VAR, 1))(
      [
        map("slash").to$(
          "open raycast-x://extensions/raycast/navigation/search-menu-items",
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

    withCondition(ifVar(HYPER_VAR, 1))([
      map("o").to(enterLeaderMenu("root")),
    ]),

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

const karabinerJsonPath = path.join(__dirname, "./karabiner.json");

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
