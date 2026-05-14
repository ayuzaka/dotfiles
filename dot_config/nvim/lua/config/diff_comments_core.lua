--- 行コメントのコア機能（永続化・CRUD・Git toplevel 解決）
-- diffview に依存しない純粋なロジック層

local M = {}

-- コメント JSON の保存先
local state_path = vim.fn.stdpath("state") .. "/diff_comments.json"
-- メモリキャッシュ（単一プロセス前提）
local cache = nil

-- ヘルパー: vim.notify のラッパー
local function notify(message, level)
  vim.notify(message, level or vim.log.levels.ERROR)
end

-- ───────────────────────────────────────────────────────────────
-- 永続化層
-- ───────────────────────────────────────────────────────────────

-- JSON ファイルから全コメントを読み込む
-- メモリキャッシュがあればそれを返し、なければファイルから読み込む
-- ファイルが存在しない・空・破損している場合は空テーブルを返す
function M.read_all()
  if cache ~= nil then
    return cache
  end

  if vim.fn.filereadable(state_path) == 0 then
    cache = {}
    return cache
  end

  local lines = vim.fn.readfile(state_path)
  if #lines == 0 then
    cache = {}
    return cache
  end

  local ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok or type(decoded) ~= "table" then
    notify("Failed to read diff comments: " .. state_path)
    cache = {}
    return cache
  end

  cache = decoded
  return cache
end

-- JSON ファイルに全コメントを書き出す
-- 書き込み成功後にメモリキャッシュも更新する
-- 親ディレクトリが存在しない場合は自動作成
local function write_all(data)
  local mkdir_ok, mkdir_err = pcall(vim.fn.mkdir, vim.fn.fnamemodify(state_path, ":h"), "p")
  if not mkdir_ok then
    notify("Failed to create directory for diff comments: " .. tostring(mkdir_err), vim.log.levels.ERROR)
    return false
  end

  local ok, encoded = pcall(vim.json.encode, data)
  if not ok then
    notify("Failed to encode diff comments", vim.log.levels.ERROR)
    return false
  end

  local write_ok, err = pcall(vim.fn.writefile, vim.split(encoded, "\n"), state_path)
  if not write_ok then
    notify("Failed to save diff comments: " .. err, vim.log.levels.ERROR)
    return false
  end

  cache = data
  return true
end

-- ───────────────────────────────────────────────────────────────
-- Git toplevel 解決
-- ───────────────────────────────────────────────────────────────

-- 絶対パスから Git toplevel を Lua ネイティブ API で解決する
-- Git リポジトリ外の場合は nil を返す
function M.get_toplevel_for_path(abspath)
  local dir = vim.fn.isdirectory(abspath) == 1 and abspath or vim.fn.fnamemodify(abspath, ":h")
  local git_dir = vim.fs.find(".git", { upward = true, path = dir })
  if not git_dir or #git_dir == 0 then
    return nil
  end
  return vim.fn.fnamemodify(git_dir[1], ":h")
end

-- ───────────────────────────────────────────────────────────────
-- CRUD
-- ───────────────────────────────────────────────────────────────

-- 指定ファイルのコメント一覧を取得する
-- 返値: { ["line"] = "body", ... } または nil
function M.get_comments(toplevel, relpath)
  local data = M.read_all()
  local repo = data[toplevel]
  if not repo then
    return nil
  end
  return repo[relpath]
end

-- コメントを追加・更新する
function M.set_comment(toplevel, relpath, line, body)
  local data = M.read_all()
  data[toplevel] = data[toplevel] or {}
  data[toplevel][relpath] = data[toplevel][relpath] or {}
  data[toplevel][relpath][tostring(line)] = body
  return write_all(data)
end

-- コメントを削除する
-- ファイル・リポジトリが空になった場合はキーを掃除する
function M.delete_comment(toplevel, relpath, line)
  local data = M.read_all()
  if not data[toplevel] then
    return true
  end
  if not data[toplevel][relpath] then
    return true
  end

  data[toplevel][relpath][tostring(line)] = nil

  if vim.tbl_isempty(data[toplevel][relpath]) then
    data[toplevel][relpath] = nil
  end
  if vim.tbl_isempty(data[toplevel]) then
    data[toplevel] = nil
  end

  return write_all(data)
end

return M
