---
name: owasp-security-review
description: OWASP Cheat Sheet Series に基づくセキュリティレビューと実装支援。コードレビュー依頼、セキュリティ関連の実装・調査、脆弱性チェック時に使用する。XSS, SQL Injection, CSRF, 認証認可などのセキュリティトピックを扱う。
---

# OWASP Security Review

OWASP Cheat Sheet Series に基づいてコードのセキュリティレビューを行い、脆弱性の指摘と改善案を提示する。

## Setup

Cheat Sheet リポジトリが未取得の場合:

```bash
bash scripts/setup_cheatsheets.sh
```

デフォルトで `~/.local/share/owasp-cheatsheets` に clone される。

## Review Workflow

### 1. Identify Security Concerns

コードから関連するセキュリティカテゴリを特定する:

| Code Pattern | OWASP Top 10 Category |
|--------------|----------------------|
| User input handling | A03: Injection |
| SQL queries | A03: Injection |
| HTML output | A03: Injection (XSS) |
| Authentication logic | A07: Authentication Failures |
| Session handling | A07: Authentication Failures |
| Access control checks | A01: Broken Access Control |
| Cryptography, passwords | A02: Cryptographic Failures |
| File uploads | A05: Security Misconfiguration |
| External API calls | A10: SSRF |
| Deserialization | A08: Data Integrity Failures |
| Dependencies | A06: Vulnerable Components |
| Logging | A09: Logging Failures |

### 2. Load Relevant Cheat Sheets

[top10-mapping.md](references/top10-mapping.md) を参照し、該当する Cheat Sheet を特定する。

Cheat Sheet の読み込み:

```bash
cat ~/.local/share/owasp-cheatsheets/cheatsheets/<CheatSheet_Name>.md
```

### 3. Review and Report

#### Output Format for Code Review

```markdown
## Security Review Summary

### Findings

#### [Severity: Critical/High/Medium/Low] Finding Title
- **Location**: file:line
- **Issue**: 問題の説明
- **OWASP Category**: A0X: Category Name
- **Reference**: Cheat Sheet name
- **Recommendation**: 改善案とコード例
```

#### Output Format for Implementation/Research

Cheat Sheet の内容を踏まえた実装ガイドまたは調査結果を提示する。必ず根拠となる Cheat Sheet を明示する。

## Quick Reference

### Common Vulnerabilities Checklist

- [ ] SQL/NoSQL Injection: パラメータ化クエリの使用
- [ ] XSS: 出力エンコーディング、CSP
- [ ] CSRF: トークン検証
- [ ] Authentication: 強力なパスワードポリシー、MFA
- [ ] Session: セキュアな設定、適切な有効期限
- [ ] Access Control: 認可チェックの一貫性
- [ ] Secrets: ハードコードされた秘密情報
- [ ] File Upload: ファイルタイプ検証、保存場所
- [ ] Error Handling: 情報漏洩防止
- [ ] Logging: 機密情報の除外
