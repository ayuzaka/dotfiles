local api = require("wiktionary.api")
local core = require("wiktionary.core")
local parser = require("wiktionary.parser")
local ui = require("wiktionary.ui")
local utils = require("config.utils")

local M = {}

local defaults = {
  border = "rounded",
  cache = true,
  max_definitions = 5,
  max_height = 30,
  max_width = 80,
  search_limit = 10,
  user_agent = "nvim-wiktionary/0.1",
}

local config = vim.deepcopy(defaults)
local engine = nil

local function get_engine()
  if not engine then
    local client = api.new({ user_agent = config.user_agent })
    engine = core.new({
      client = client,
      config = config,
      parser = parser,
      ui = ui,
    })
  end

  return engine
end

function M.setup(options)
  config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), options or {})
  engine = nil
  return M
end

function M.lookup()
  get_engine().lookup(vim.fn.expand("<cword>"))
end

function M.lookup_visual(start_line, end_line)
  local query = start_line and utils.get_range_query_text(start_line, end_line) or utils.get_visual_query_text()
  get_engine().lookup(query)
end

return M
