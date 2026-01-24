import { defineConfig } from "jsr:@yuki-yano/zeno";

export default defineConfig(() => ({
  snippets: [
    {
      name: "git push ----force-with-lease",
      keyword: "gpf",
      snippet: "git push --force-with-lease",
    },
    {
      name: "git tree",
      keyword: "git-tree",
      snippet:
        "git log --graph --pretty=format:'%x09%C(auto) %h %Cgreen %cd %Creset%x09%C(cyan ul)%an%Creset %x09%C(auto)%s %d' --date=format:'%Y-%m-%d (%a)'",
    },
    {
      name: "git switch main",
      keyword: "gm",
      snippet: "git switch main",
    },
    {
      name: "git switch",
      keyword: "gs",
      snippet: "git switch",
    },
    {
      name: "git checkout",
      keyword: "gc",
      snippet: "git checkout",
    },
    {
      name: "show latest commit hash",
      keyword: "gch",
      snippet: "git rev-parse HEAD",
    },
    {
      name: "git quicksave",
      keyword: "gsave",
      snippet: "git_quicksave",
    },
    {
      name: "my PR",
      keyword: "gh-pr-me",
      snippet: 'gh pr list --author "@me" --state all',
    },
    {
      name: "search PR",
      keyword: "gh-pr-search",
      snippet:
        "gh pr list --state all --json number,title --jq \".[] | [.number,.title] | @csv\" --search \"{{text}}\" | fzf | awk -F ',' '{print $1}' | xargs gh browse",
    },
    {
      name: "gh copilot explain",
      keyword: "ghe",
      snippet: 'gh copilot explain "{{text}}"',
    },
    {
      name: "restore quicksave",
      keyword: "restore",
      snippet: "git checkout {{text}} -- ."
    }
  ],
  completions: [
    {
      name: "git switch",
      patterns: [
        "^git switch(?: .*)? $",
      ],
      sourceCommand:
        "git for-each-ref --format='%(refname:short) - %(contents:subject)' refs/heads/ | grep -v '^$(git symbolic-ref --short HEAD) -'",
      options: {
        "--height": "80%",
        "--print0": true,
        "--preview-window": "down",
        "--prompt": "'Git Switch > ' ",
      },
      callback: "awk '{print $1}'",
    },
    {
      name: "git-wt switch",
      patterns: [
        "^git wt? $",
      ],
      sourceCommand: "git wt | grep -v -F -e '*' -e 'BRANCH' | awk '{print $2}'",
      options: {
        "--height": "80%",
        "--print0": true,
        "--preview-window": "down",
        "--prompt": "'git-wt Switch > ' ",
      },
      callback: "",
    },
    {
      name: "gw delete",
      patterns: [
        "^git wt -(d|D)? $",
      ],
      sourceCommand: "git wt | grep -v -F -e '*' -e 'BRANCH' | awk '{print $2}'",
      options: {
        "--height": "80%",
        "--print0": true,
        "--preview-window": "down",
        "--prompt": "'Git Worktree Remove > ' ",
      },
      callback: "",
    },
    {
      name: "git branch delete",
      patterns: [
        "^git branch -d(?: .*)? $",
      ],
      sourceCommand:
        "git for-each-ref --format='%(refname:short)' refs/heads --merged | grep -v -x -F -e develop -e main -e master -e \"$(git symbolic-ref --short HEAD)\"",
      options: {
        "--height": "80%",
        "--print0": true,
        "--preview-window": "down",
        "--prompt": "'Git Branch Delete > ' ",
      },
      callback: "awk '{print $1}'",
    },
    {
      name: "gh issue edit",
      patterns: [
        "^gh issue edit(?: .*)? $",
      ],
      sourceCommand: "gh issue list --assignee @me --state open --limit 1000",
      options: {
        "--height": "80%",
        "--print0": true,
        "--preview-window": "down",
        "--prompt": "'gh issue edit > ' ",
      },
      callback: "awk '{print $1}'",
    }
  ],
}));
