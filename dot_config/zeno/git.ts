import { defineConfig } from "jsr:@yuki-yano/zeno";

export default defineConfig(() => ({
  "snippets": [
    {
      "name": "git push ----force-with-lease",
      "keyword": "gpf",
      "snippet": "git push --force-with-lease",
    },
    {
      "name": "git tree",
      "keyword": "git-tree",
      "snippet":
        "git log --graph --pretty=format:'%x09%C(auto) %h %Cgreen %cd %Creset%x09%C(cyan ul)%an%Creset %x09%C(auto)%s %d' --date=format:'%Y-%m-%d (%a)'",
    },
    {
      "name": "git switch main",
      "keyword": "gm",
      "snippet": "git switch main",
    },
    {
      "name": "git switch",
      "keyword": "gs",
      "snippet": "git switch",
    },
    {
      "name": "git checkout",
      "keyword": "gc",
      "snippet": "git checkout",
    },
    {
      "name": "show latest commit hash",
      "keyword": "gch",
      "snippet": "git rev-parse HEAD",
    },
    {
      "name": "my PR",
      "keyword": "gh-pr-me",
      "snippet": 'gh pr list --author "@me" --state all',
    },
    {
      "name": "search PR",
      "keyword": "gh-pr-search",
      "snippet":
        "gh pr list --state all --json number,title --jq \".[] | [.number,.title] | @csv\" --search \"{{text}}\" | fzf | awk -F ',' '{print $1}' | xargs gh browse",
    },
    {
      "name": "gh copilot explain",
      "keyword": "ghe",
      "snippet": 'gh copilot explain "{{text}}"',
    },
  ],
  "completions": [
    {
      "name": "git switch",
      "patterns": [
        "^git switch(?: .*)? $",
      ],
      "sourceCommand":
        "git for-each-ref --format='%(refname:short) - %(contents:subject)' refs/heads/ | grep -v '^$(git symbolic-ref --short HEAD) -'",
      "options": {
        "--height": "80%",
        "--print0": true,
        "--preview-window": "down",
        "--prompt": "'Git Switch > ' ",
      },
      "callback": "awk '{print $1}'",
    },
    {
      "name": "git remove worktree",
      "patterns": [
        "^git worktree remove(?: .*)? $",
      ],
      "sourceCommand": "git worktree list | grep -v 'main' | awk '{print $1}'",
      "options": {
        "--height": "80%",
        "--print0": true,
        "--preview-window": "down",
        "--prompt": "'Git Worktree Remove > ' ",
      },
      "callback": "awk '{print $1}'",
    },
    {
      "name": "git checkout remote branch",
      "patterns": [
        "git checkout(?: .*)? $",
      ],
      "sourceCommand": "git branch -r | grep -v '*' | sed 's/origin\\///'",
      "options": {
        "--height": "80%",
        "--print0": true,
        "--preview-window": "down",
        "--prompt": "'Git Switch > ' ",
      },
      "callback": "awk '{print $1}'",
    },
    {
      "name": "git branch delete",
      "patterns": [
        "^git branch -d(?: .*)? $",
      ],
      "sourceCommand":
        "git for-each-ref --format='%(refname:short)' refs/heads --merged | grep -v -x -F -e develop -e main -e master -e \"$(git symbolic-ref --short HEAD)\"",
      "options": {
        "--height": "80%",
        "--print0": true,
        "--preview-window": "down",
        "--prompt": "'Git Branch Delete > ' ",
      },
      "callback": "awk '{print $1}'",
    },
    {
      "name": "git branch delete force",
      "patterns": [
        "^git branch -D(?: .*)? $",
      ],
      "sourceCommand":
        "git for-each-ref --format='%(refname:short)' refs/heads | grep -v -x -F -e develop -e main -e master -e \"$(git symbolic-ref --short HEAD)\"",
      "options": {
        "--height": "80%",
        "--print0": true,
        "--preview-window": "down",
        "--prompt": "'Git Branch Delete > ' ",
      },
      "callback": "awk '{print $1}'",
    },
  ],
}));
