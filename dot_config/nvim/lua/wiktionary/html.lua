local M = {}

local named_entities = {
  amp = "&",
  apos = "'",
  emsp = " ",
  ensp = " ",
  gt = ">",
  hellip = "…",
  laquo = "«",
  lt = "<",
  mdash = "—",
  middot = "·",
  nbsp = " ",
  ndash = "–",
  quot = '"',
  raquo = "»",
  thinsp = " ",
}

local void_tags = {
  area = true,
  base = true,
  br = true,
  col = true,
  embed = true,
  hr = true,
  img = true,
  input = true,
  link = true,
  meta = true,
  param = true,
  source = true,
  track = true,
  wbr = true,
}

local function decode_entity(entity)
  if entity:sub(1, 1) ~= "#" then
    return named_entities[entity] or "&" .. entity .. ";"
  end

  local number
  if entity:sub(2, 2):lower() == "x" then
    number = tonumber(entity:sub(3), 16)
  else
    number = tonumber(entity:sub(2), 10)
  end

  if not number or number < 0 or number > 0x10FFFF then
    return "&" .. entity .. ";"
  end

  local ok, character = pcall(vim.fn.nr2char, number)
  return ok and character or "&" .. entity .. ";"
end

local function decode_entities(text)
  return (text:gsub("&([#xX%w]+);", decode_entity))
end

local function find_tag_end(source, start_index)
  local quote = nil

  for index = start_index, #source do
    local character = source:sub(index, index)
    if quote then
      if character == quote then
        quote = nil
      end
    elseif character == '"' or character == "'" then
      quote = character
    elseif character == ">" then
      return index
    end
  end

  return nil
end

local function append_text(tokens, value)
  if value ~= "" then
    table.insert(tokens, { kind = "text", value = decode_entities(value) })
  end
end

local function class_attribute(raw_tag)
  return raw_tag:match('class%s*=%s*"([^"]*)"')
    or raw_tag:match("class%s*=%s*'([^']*)'")
end

function M.tokenize(source)
  if type(source) ~= "string" then
    return nil, "invalid_source"
  end

  local tokens = {}
  local cursor = 1

  while cursor <= #source do
    local tag_start = source:find("<", cursor, true)
    if not tag_start then
      append_text(tokens, source:sub(cursor))
      break
    end

    append_text(tokens, source:sub(cursor, tag_start - 1))

    if source:sub(tag_start, tag_start + 3) == "<!--" then
      local comment_end = source:find("-->", tag_start + 4, true)
      if not comment_end then
        return nil, "unterminated_comment"
      end
      cursor = comment_end + 3
    else
      local tag_end = find_tag_end(source, tag_start + 1)
      if not tag_end then
        return nil, "unterminated_tag"
      end

      local raw_tag = source:sub(tag_start + 1, tag_end - 1)
      if not raw_tag:match("^%s*[!?]") then
        local closing = raw_tag:match("^%s*/") ~= nil
        local name = raw_tag:match("^%s*/?%s*([%w:_-]+)")
        if not name then
          return nil, "invalid_tag"
        end

        name = name:lower()
        if closing then
          table.insert(tokens, { kind = "end", name = name })
        else
          table.insert(tokens, {
            class = class_attribute(raw_tag),
            kind = "start",
            name = name,
            self_closing = void_tags[name] == true or raw_tag:match("/%s*$") ~= nil,
          })
        end
      end

      cursor = tag_end + 1
    end
  end

  return tokens, nil
end

return M
