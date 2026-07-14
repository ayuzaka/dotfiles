local parser = require("wiktionary.parser")

local representative_html = [[
<div class="mw-parser-output">
  <div class="mw-heading mw-heading2">
    <h2 id="日本語">日本語</h2>
    <span class="mw-editsection">[編集]</span>
  </div>
  <div class="mw-heading mw-heading3"><h3 id="語源">語源</h3></div>
  <ol><li>語源の番号付き項目は除外する。</li></ol>
  <div class="mw-heading mw-heading3"><h3 id="名詞">名詞</h3></div>
  <p>見出し語の説明</p>
  <ol>
    <li><a href="/wiki/第一">第一の意味</a> &amp; 補足<sup class="reference">[1]</sup><ul><li>短い用例</li></ul><table><tr><td>大きな表</td></tr></table><blockquote>長い引用</blockquote></li>
    <li>第二の意味</li>
    <li>第三の意味</li>
    <li>第四の意味</li>
    <li>第五の意味</li>
    <li>第六の意味</li>
  </ol>
  <div class="mw-heading mw-heading4"><h4 id="関連語">関連語</h4></div>
  <ol><li>関連語の番号付き項目は除外する。</li></ol>
  <div class="mw-heading mw-heading3"><h3 id="動詞">動詞</h3></div>
  <ol><li><span>動作を表す。</span></li></ol>
  <div class="mw-heading mw-heading2"><h2 id="中国語">中国語</h2></div>
  <div class="mw-heading mw-heading3"><h3 id="名詞_2">名詞</h3></div>
  <ol><li>外国語の意味は除外する。</li></ol>
</div>
]]

describe("wiktionary.parser", function()
  it("extracts only definitions under supported parts of speech in the Japanese section", function()
    local entries, err = parser.extract(representative_html)

    assert.is_nil(err)
    assert.are.same({
      {
        part_of_speech = "名詞",
        definitions = {
          "第一の意味 & 補足 短い用例",
          "第二の意味",
          "第三の意味",
          "第四の意味",
          "第五の意味",
          "第六の意味",
        },
      },
      {
        part_of_speech = "動詞",
        definitions = { "動作を表す。" },
      },
    }, entries)
  end)

  it("distinguishes a missing Japanese section", function()
    local entries, err = parser.extract("<h2>中国語</h2><h3>名詞</h3><ol><li>意味</li></ol>")

    assert.is_nil(entries)
    assert.are.equal("missing_japanese", err.kind)
  end)

  it("distinguishes a Japanese section without supported definitions", function()
    local entries, err = parser.extract("<h2>日本語</h2><h3>語源</h3><p>説明</p>")

    assert.is_nil(entries)
    assert.are.equal("no_definitions", err.kind)
  end)

  it("distinguishes malformed HTML", function()
    local entries, err = parser.extract("<div")

    assert.is_nil(entries)
    assert.are.equal("html_parse", err.kind)
  end)
end)
