const path = require("node:path");
const os = require("node:os");

// getConfigBaseDir() は探索で見つかった textlintrc 自体のパスの dirname になり、
// symlink 越しに発見されると相対 dictionaryPath が壊れるため絶対パスに固定する
const textlintDir = path.join(os.homedir(), ".config/textlint");
const config = require(path.join(textlintDir, ".textlintrc.json"));
config.rules["preset-ai-words-ja"]["no-ai-words"].dictionaryPath = path.join(
  textlintDir,
  "ai-words-ja.json",
);

module.exports = config;
