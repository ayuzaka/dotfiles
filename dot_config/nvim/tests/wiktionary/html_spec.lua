local html = require("wiktionary.html")

describe("wiktionary.html", function()
  it("tokenizes tags without treating a quoted angle bracket as the tag end", function()
    local tokens, reason = html.tokenize([[
      <!-- ignored -->
      <div class="definition primary" data-label="1 > 0">A&amp;B<br>C&#x65E5;</div>
    ]])

    assert.is_nil(reason)
    assert.are.same({
      { kind = "text", value = "      " },
      { kind = "text", value = "\n      " },
      {
        class = "definition primary",
        kind = "start",
        name = "div",
        self_closing = false,
      },
      { kind = "text", value = "A&B" },
      {
        class = nil,
        kind = "start",
        name = "br",
        self_closing = true,
      },
      { kind = "text", value = "C日" },
      { kind = "end", name = "div" },
      { kind = "text", value = "\n    " },
    }, tokens)
  end)

  it("reports an unterminated tag", function()
    local tokens, reason = html.tokenize("<div")

    assert.is_nil(tokens)
    assert.are.equal("unterminated_tag", reason)
  end)

  it("reports an unterminated comment", function()
    local tokens, reason = html.tokenize("<!-- broken")

    assert.is_nil(tokens)
    assert.are.equal("unterminated_comment", reason)
  end)
end)
