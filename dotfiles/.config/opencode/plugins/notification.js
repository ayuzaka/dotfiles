export const NotificationPlugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type !== "session.idle" && event.type !== "permission.asked") {
        return;
      }

      let ghqRoot = ""
      let toplevel = ""
      let branch = ""

      try { ghqRoot = (await $`ghq root`.quiet()).text().trim() } catch {}
      try { toplevel = (await $`git rev-parse --show-toplevel`.quiet()).text().trim() } catch {}
      try { branch = (await $`git rev-parse --abbrev-ref HEAD`.quiet()).text().trim() } catch {}

      if (toplevel.includes("/.git-wt/")) {
        toplevel = toplevel.replace(/\/\.git-wt\/.*/, "")
      }

      let project = "OpenCode"
      if (toplevel) {
        if (ghqRoot && toplevel.startsWith(ghqRoot)) {
          const rel = toplevel.slice(ghqRoot.length + 1);
          const parts = rel.split("/")
          project = parts.slice(1).join("/");
        } else {
          project = toplevel.split("/").pop();
        }

        if (branch && branch !== "HEAD") {
          project += ` - ${branch}`;
        }
      }

      const message = event.type === "permission.asked" ? "権限の承認が必要です" : "処理が完了しました";

      await $`osascript -e 'display notification "${message}" with title "OpenCode" subtitle "${project}"'`
    },
  }
}
