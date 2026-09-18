import type { Plugin } from "@opencode/plugin";
import { Glob } from "bun";
import { execFile } from "node:child_process";
import { homedir } from "node:os";
import { resolve } from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
type PluginContext = Parameters<
  NonNullable<Parameters<typeof Plugin.define>[0]["setup"]>
>[0];

const POST_EDIT_HOOKS = [
  {
    name: "Format Langfuse repository file",
    glob: "~/dev/repos/langfuse/langfuse/**/*.{ts,tsx}",
    callback: async (filePath: string) => {
      await execFileAsync("pnpm", ["exec", "prettier", "--write", filePath]);
    },
  },
  {
    name: "Format Langfuse worktree file",
    glob: "~/dev/worktrees/langfuse/**/*.{ts,tsx}",
    callback: async (filePath: string) => {
      await execFileAsync("pnpm", ["exec", "prettier", "--write", filePath]);
    },
  },
];

export default {
  id: "post-edit-hooks",
  async setup(ctx: PluginContext) {
    await ctx.tool.hook("execute.after", async (event) => {
      if (!["write", "edit", "apply_patch"].includes(event.tool)) return;

      const input = event.input as Record<string, unknown>;

      const suppliedPath = input.file_path ?? input.filePath ?? input.path;
      const filePaths = new Set<string>();

      if (typeof suppliedPath === "string") {
        filePaths.add(resolve(suppliedPath));
      }

      if (typeof input.patchText === "string") {
        for (const match of input.patchText.matchAll(
          /^\*\*\* (?:Add|Update) File: (.+)$|^\*\*\* Move to: (.+)$/gm,
        )) {
          filePaths.add(resolve(match[1] ?? match[2]));
        }
      }

      for (const filePath of filePaths) {
        for (const hook of POST_EDIT_HOOKS) {
          const glob = hook.glob.replace(/^~(?=\/)/, homedir());

          if (new Glob(glob).match(filePath)) {
            try {
              await hook.callback(filePath);
              await ctx.tui.showToast({
                body: {
                  title: "Post-edit hook",
                  message: `${hook.name}: ${filePath}`,
                  variant: "success",
                  duration: 3000,
                },
              });
            } catch (error) {
              await ctx.tui.showToast({
                body: {
                  title: `${hook.name} failed`,
                  message:
                    error instanceof Error ? error.message : String(error),
                  variant: "error",
                  duration: 5000,
                },
              });
              throw error;
            }
          }
        }
      }
    });
  },
};
