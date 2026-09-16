import type { Plugin } from "@opencode-ai/plugin";
import { Glob } from "bun";
import { execFile } from "node:child_process";
import { homedir } from "node:os";
import { resolve } from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

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

const PostEditHooks: Plugin = async ({ client }) => ({
  "tool.execute.after": async (input) => {
    if (!["write", "edit", "apply_patch"].includes(input.tool)) return;

    const suppliedPath =
      input.args.file_path ?? input.args.filePath ?? input.args.path;
    const filePaths = new Set<string>();

    if (typeof suppliedPath === "string") {
      filePaths.add(resolve(suppliedPath));
    }

    if (typeof input.args.patchText === "string") {
      for (const match of input.args.patchText.matchAll(
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
            await client.tui.showToast({
              body: {
                title: "Post-edit hook",
                message: `${hook.name}: ${filePath}`,
                variant: "success",
                duration: 3000,
              },
            });
          } catch (error) {
            await client.tui.showToast({
              body: {
                title: `${hook.name} failed`,
                message: error instanceof Error ? error.message : String(error),
                variant: "error",
                duration: 5000,
              },
            });
            throw error;
          }
        }
      }
    }
  },
});

export default PostEditHooks;
