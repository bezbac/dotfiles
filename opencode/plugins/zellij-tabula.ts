import type { Plugin } from "@opencode/plugin";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
type PluginContext = Parameters<
  NonNullable<Parameters<typeof Plugin.define>[0]["setup"]>
>[0];

export default {
  id: "zellij-tabula",
  async setup(ctx: PluginContext) {
    console.info("Zellij-tabula plugin initialized");

    let globalStatus: "waiting" | "none" = "none";

    async function setPaneStatus(status: "waiting" | "none") {
      if (globalStatus === status) {
        return;
      }

      globalStatus = status;

      const paneId = process.env.ZELLIJ_PANE_ID;

      if (paneId === undefined) {
        console.debug(
          "ZELLIJ_PANE_ID environment variable is not set. Skipping pane status update.",
        );

        return;
      }

      console.debug(
        `Setting zellij pane status to '${status}' for pane ID '${paneId}'`,
      );

      await execFileAsync("zellij", [
        "pipe",
        "--name",
        "tabula",
        "--",
        `status '${paneId}' '${status}'`,
      ]);
    }

    await setPaneStatus("none");

    const controller = new AbortController();

    void (async () => {
      for await (const event of ctx.event.subscribe({
        signal: controller.signal,
      })) {
        if (event.type === "permission.asked") {
          await setPaneStatus("waiting");
        }

        if (event.type === "permission.replied") {
          await setPaneStatus("none");
        }
      }
    })();

    return async () => {
      controller.abort();
      await setPaneStatus("none");
    };
  },
};
