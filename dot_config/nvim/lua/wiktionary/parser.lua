local html = require("wiktionary.html")

local M = {}

local supported_parts_of_speech = {
  ["名詞"] = true,
  ["動詞"] = true,
  ["形容詞"] = true,
  ["形容動詞"] = true,
  ["副詞"] = true,
  ["連体詞"] = true,
  ["接続詞"] = true,
  ["感動詞"] = true,
  ["助詞"] = true,
  ["助動詞"] = true,
  ["接頭辞"] = true,
  ["接尾辞"] = true,
  ["成句"] = true,
  ["慣用句"] = true,
  ["ことわざ"] = true,
}

local ignored_tags = {
  blockquote = true,
  script = true,
  style = true,
  sup = true,
  table = true,
}

local ignored_classes = {
  ["mw-cite-backlink"] = true,
  ["mw-editsection"] = true,
  reference = true,
  references = true,
}

local function has_ignored_class(class_attribute)
  for class_name in (class_attribute or ""):gmatch("%S+") do
    if ignored_classes[class_name] then
      return true
    end
  end

  return false
end

local function should_ignore(token)
  return ignored_tags[token.name] == true or has_ignored_class(token.class)
end

local function clean_text(parts)
  local text = table.concat(parts, " ")
  text = text:gsub("​", "")
  text = text:gsub("%s*%[%d+%]%s*", " ")
  text = text:gsub("%s+", " ")
  return vim.trim(text)
end

local function heading_level(name)
  return tonumber(name:match("^h([2-6])$"))
end

function M.extract(source)
  local tokens, token_error = html.tokenize(source)
  if not tokens then
    return nil, { kind = "html_parse", reason = token_error }
  end

  local entries = {}
  local found_japanese = false
  local in_japanese = false
  local active_entry = nil
  local heading = nil
  local ignored_depth = 0
  local ordered_depth = 0
  local list_item_depth = 0
  local definition_parts = nil

  local function finish_heading()
    local text = clean_text(heading.parts)
    local level = heading.level
    heading = nil

    if level == 2 then
      in_japanese = text == "日本語"
      found_japanese = found_japanese or in_japanese
      active_entry = nil
      return
    end

    if not in_japanese then
      active_entry = nil
      return
    end

    if supported_parts_of_speech[text] then
      active_entry = {
        part_of_speech = text,
        definitions = {},
      }
      table.insert(entries, active_entry)
    else
      active_entry = nil
    end
  end

  local function finish_definition()
    local definition = clean_text(definition_parts)
    definition_parts = nil
    if definition ~= "" then
      table.insert(active_entry.definitions, definition)
    end
  end

  for _, token in ipairs(tokens) do
    if ignored_depth > 0 then
      if token.kind == "start" and not token.self_closing then
        ignored_depth = ignored_depth + 1
      elseif token.kind == "end" then
        ignored_depth = ignored_depth - 1
      end
    elseif token.kind == "start" and should_ignore(token) then
      if not token.self_closing then
        ignored_depth = 1
      end
    elseif token.kind == "start" then
      local level = heading_level(token.name)
      if level then
        heading = { level = level, name = token.name, parts = {} }
      elseif token.name == "ol" then
        ordered_depth = ordered_depth + 1
      elseif token.name == "li" then
        list_item_depth = list_item_depth + 1
        if active_entry and ordered_depth == 1 and list_item_depth == 1 then
          definition_parts = {}
        elseif definition_parts then
          table.insert(definition_parts, " ")
        end
      elseif definition_parts and (token.name == "br" or token.name == "p") then
        table.insert(definition_parts, " ")
      end
    elseif token.kind == "text" then
      if heading then
        table.insert(heading.parts, token.value)
      elseif definition_parts then
        table.insert(definition_parts, token.value)
      end
    elseif token.kind == "end" then
      if heading and token.name == heading.name then
        finish_heading()
      elseif token.name == "li" then
        if definition_parts and list_item_depth == 1 then
          finish_definition()
        end
        list_item_depth = math.max(0, list_item_depth - 1)
      elseif token.name == "ol" then
        ordered_depth = math.max(0, ordered_depth - 1)
      end
    end
  end

  if not found_japanese then
    return nil, { kind = "missing_japanese" }
  end

  local populated_entries = {}
  for _, entry in ipairs(entries) do
    if #entry.definitions > 0 then
      table.insert(populated_entries, entry)
    end
  end

  if #populated_entries == 0 then
    return nil, { kind = "no_definitions" }
  end

  return populated_entries, nil
end

return M
