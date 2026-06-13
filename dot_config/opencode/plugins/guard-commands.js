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

      const newCommand = command.replace(/\bgrep\b/g, "rg");
      if (newCommand !== command) {
        output.args.command = newCommand;
      }
    },
  };
};
