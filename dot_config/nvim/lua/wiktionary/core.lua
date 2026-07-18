local M = {}

local function normalize_query(query)
  local normalized = tostring(query or ""):gsub("[\r\n]+", " ")
  return vim.trim(normalized)
end

local function page_url(title)
  return "https://ja.wiktionary.org/wiki/" .. vim.uri_encode(title, "rfc3986")
end

function M.new(dependencies)
  local cache = {}
  local pending = {}
  local client = dependencies.client
  local config = dependencies.config
  local now = dependencies.now or os.time
  local parser = dependencies.parser
  local ui = dependencies.ui

  local lookup_page
  local search_candidates

  local function finish(query)
    pending[query] = nil
  end

  local function notify_error(err, query, title)
    local messages = {
      api = "Wiktionary APIでエラーが発生しました。",
      curl_missing = "curlが見つかりません。",
      json = "Wiktionary APIの応答を解析できませんでした。",
      network = "Wiktionaryへの接続に失敗しました。",
    }
    local message = messages[err.kind]

    if err.kind == "not_found" then
      message = string.format('Wiktionaryに「%s」のページが見つかりませんでした。', query)
    elseif err.kind == "missing_japanese" then
      message = string.format('Wiktionaryの「%s」ページに日本語セクションがありません。', title)
    elseif err.kind == "no_definitions" then
      message = "語義を抽出できませんでした。\n" .. page_url(title)
    elseif err.kind == "html_parse" then
      message = "WiktionaryのHTMLを解析できませんでした。\n" .. page_url(title)
    end

    ui.notify(message or "Wiktionaryの検索に失敗しました。", vim.log.levels.ERROR)
  end

  local function handle_page(query, page)
    local entries, extraction_error = parser.extract(page.html)
    if extraction_error then
      notify_error(extraction_error, query, page.title)
      finish(query)
      return
    end

    local result = {
      entries = entries,
      fetched_at = now(),
      page_title = page.title,
      query = query,
    }
    if config.cache then
      cache[query] = result
    end

    ui.show(result, config)
    finish(query)
  end

  search_candidates = function(query)
    client.search(query, config.search_limit, function(candidates, search_error)
      if search_error then
        notify_error(search_error, query, query)
        finish(query)
        return
      end

      if #candidates == 0 then
        notify_error({ kind = "not_found" }, query, query)
        finish(query)
        return
      end

      ui.select(candidates, query, function(choice)
        if not choice then
          finish(query)
          return
        end
        lookup_page(query, choice, false)
      end)
    end)
  end

  lookup_page = function(query, title, search_when_missing)
    client.parse(title, function(page, request_error)
      if request_error then
        if request_error.kind == "not_found" and search_when_missing then
          search_candidates(query)
        else
          notify_error(request_error, query, title)
          finish(query)
        end
        return
      end

      handle_page(query, page)
    end)
  end

  local function lookup(raw_query)
    local query = normalize_query(raw_query)
    if query == "" then
      ui.notify("検索語を取得できませんでした。", vim.log.levels.WARN)
      return
    end

    if pending[query] then
      return
    end

    if config.cache and cache[query] then
      ui.show(cache[query], config)
      return
    end

    pending[query] = true
    lookup_page(query, query, true)
  end

  return { lookup = lookup }
end

return M
