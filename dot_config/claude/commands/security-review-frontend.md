---
description: "OWASP Cheat Sheet に基づくフロントエンドセキュリティレビュー"
---

OWASP Cheat Sheet Series に基づくセキュリティレビューを実施してください。

## レビュー対象

$ARGUMENTS

引数が指定されていない場合は、プロジェクト全体を対象とする。
その場合、まずプロジェクト構造を把握し、セキュリティ上重要なファイルを特定してからレビューを行う。

## レビュー観点

- XSS (Cross-Site Scripting)
- DOM-based XSS
- CSRF
- Cookie / Session セキュリティ
- Third Party Scripts
- postMessage セキュリティ
- Prototype Pollution
- その他フロントエンド固有の脆弱性

## 出力形式

```markdown
## Security Review Summary

### Findings

#### [Critical/High/Medium/Low] Finding Title
- **Location**: file:line
- **Issue**: 問題の説明
- **Attack Vector**: 攻撃シナリオ
- **Reference**: OWASP Cheat Sheet name
- **Recommendation**: 改善案とコード例
```

問題がない場合は、確認した観点と「問題なし」の旨を報告してください。
