export const GuardCommandsPlugin = async () => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") {
        return;
      }

      const command = output.args.command;
      if (!command) {
        return;
      }

      if (/\bfind\b/.test(command)) {
        throw new Error(
          'find is not allowed. Use fd instead. Example: fd -e sh . (instead of find . -name "*.sh" -type f)',
        );
      }

      if (/\brm\b/.test(command)) {
        throw new Error(
          "rm is not allowed. Use trash instead. Example: trash file.txt (instead of rm file.txt)",
        );
      }

      if (/\bgit push\b/.test(command)) {
        throw new Error("git push is not allowed.");
      }

      if (/\bgit reset --hard\b/.test(command)) {
        throw new Error("git reset --hard is not allowed.");
      }

      if (/\bgit clean -f/.test(command)) {
        throw new Error("git clean is not allowed.");
      }

      if (/\bgit branch -D\b/.test(command)) {
        throw new Error("git branch -D is not allowed.");
      }

      if (/\bgit checkout \./.test(command)) {
        throw new Error("git checkout . is not allowed.");
      }

      if (/\bgit restore \./.test(command)) {
        throw new Error("git restore . is not allowed.");
      }

      const newCommand = command.replace(/\bgrep\b/g, "rg");
      if (newCommand !== command) {
        output.args.command = newCommand;
      }
    },
  };
};
