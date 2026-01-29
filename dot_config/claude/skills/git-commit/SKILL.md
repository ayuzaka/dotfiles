---
name: git-commit
description: Generate a commit message following project conventions and execute git commit.
user_invocable: true
---

# git-commit skill

Generate a commit message and execute `git commit`.

## Steps

1. Run `git status` and `git diff --staged` to check staged changes.
2. If there are no staged changes, run `git diff` to check unstaged changes and ask the user to stage them. Do NOT proceed with the commit until changes are staged.
3. Analyze the staged changes and generate a commit message following the rules below.
4. The commit message must describe the **intent** of the change, not just what was changed. Trivial fixes (typos, formatting) are an exception.
5. If the intent is unclear from the diff, use `AskUserQuestion` to ask the user.
6. Show the generated commit message to the user and execute `git commit` using HEREDOC format:

```sh
git commit -m "$(cat <<'EOF'
<commit message here>

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

## Commit Message Rules

Reference: @references/commit-message.md

### Prefix

Every commit message MUST start with one of these prefixes:

- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation
- `style:` formatting, missing semi colons, etc.
- `refactor:` refactoring
- `test:` when adding missing tests
- `chore:` maintain

### Subject-First Style

- You don't always need a verb if you are introducing something new. E.g., "Widget tests" is preferred over "Widget tests are added".
- Use "is corrected" rather than "is fixed". E.g., `fix: Widget reconciliation is corrected`
- When something is refactored or improved, use "is clarified". E.g., `refactor: Widget creation is clarified`
- When describing a rename, use "rather than". E.g., `refactor: Widget, rather than sprocket`
- When describing a version increase, be explicit about both versions. E.g., `chore: Package version is increased from 1.1.1 to 1.2.0`
- Don't enforce the 50-character subject limit. Make the first line as long as it needs to be. Brevity is useful, but clarity comes first.
