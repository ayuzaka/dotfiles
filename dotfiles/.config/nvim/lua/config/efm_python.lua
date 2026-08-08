local M = {}

--- efm-langserver の Python ツール設定を生成する
--- @param cmd_prefix string|nil コマンドプレフィックス (例: "docker compose exec api")
--- @return table settings vim.lsp.config("efm") に渡す settings テーブル
function M.settings(cmd_prefix)
  local p = cmd_prefix and (cmd_prefix .. " ") or ""

  return {
    languages = {
      python = {
        {
          prefix = "flake8",
          lintCommand = p .. "flake8 --stdin-display-name ${INPUT} -",
          lintStdin = true,
          lintFormats = { "%f:%l:%c: %m" },
          rootMarkers = { "setup.cfg", "pyproject.toml", "tox.ini", ".flake8" },
        },
        {
          prefix = "mypy",
          lintCommand = p .. "mypy --show-column-numbers --strict --strict-equality",
          lintFormats = { "%f:%l:%c: %t%*[^:]: %m" },
          rootMarkers = { "setup.cfg", "pyproject.toml", "mypy.ini" },
        },
        {
          formatCommand = p .. "isort --quiet -",
          formatStdin = true,
        },
        {
          formatCommand = p .. "black --quiet --safe -",
          formatStdin = true,
        },
      },
    },
  }
end

return M
