import { defineConfig } from "jsr:@yuki-yano/zeno";

export default defineConfig(() => ({
  snippets: [
    {
      name: "ls --long",
      keyword: "ll",
      snippet: "lsd -lh",
    },
    {
      name: "ls --all",
      keyword: "la",
      snippet: "lsd -lah",
    },
    {
      name: "clear",
      keyword: "cl",
      snippet: "clear",
    },
    {
      name: "devcontainer exec",
      keyword: "dcon-exec",
      snippet: "devcontainer exec --workspace-folder . /bin/bash -i",
    },
    {
      name: "golangci-lint",
      keyword: "golint",
      snippet: "golangci-lint",
    },
    {
      name: "gitui",
      keyword: "gu",
      snippet: "gitui",
    },
    {
      name: "ollama",
      keyword: "ol",
      snippet: "ollama",
    },
    {
      name: "img2sixel",
      keyword: "ls-img",
      snippet: "img2sixel",
    },
    {
      name: "gcloud switch",
      keyword: "gcloud-switch",
      snippet: "gcloud config configurations activate",
    },
    {
      name: "Output image file's width and height",
      keyword: "swh",
      snippet: "sips -g pixelWidth -g pixelHeight",
    },
    {
      name: "lazysql",
      keyword: "sql",
      snippet: "lazysql",
    },
    {
      name: "trash",
      keyword: "rm",
      snippet: "trash",
    },
    {
      name: "search process for port",
      keyword: "psp",
      snippet: 'ps -fp "$(lsof -t -i :"{{port}}")"',
    },
    {
      name: "search and copy history",
      keyword: "h",
      snippet: "cat $HISTFILE | fzf | pbcopy",
    },
  ],
  completions: [
    {
      name: "tmux attach",
      patterns: [
        "^tmux a -t(?: .*)? $",
      ],
      sourceCommand: "tmux ls",
      "options": {
        "--height": "80%",
        "--print0": true,
        "--preview-window": "down",
        "--prompt": "'tmux attach > ' ",
      },
      callback: "awk -F ':' '{print $1}'",
    },

    {
      name: "ssh login",
      patterns: [
        "^ssh(?: .*)? $",
      ],
      sourceCommand:
        "cat ~/.ssh/*.conf | grep -E '^Host\\s' | grep -v '*' | awk '{print $2}'",
      "options": {
        "--prompt": "'ssh > ' ",
      },
      callback: "",
    },
    {
      name: "npm scripts",
      patterns: [
        "npm run(?: .*)? $",
        "yarn run(?: .*)? $",
        "pnpm run(?: .*)? $",
        "bun run(?: .*)? $",
        "ni run(?: .*)? $",
      ],
      sourceCommand:
        "jq -r '.scripts | to_entries | .[] | .key + \" = \" + .value' package.json",
      "options": {
        "--prompt": "'npm run > '",
      },
      callback: "awk -F ' = ' '{ print $1 }'",
    },
    {
      name: "deno tasks",
      patterns: [
        "deno task(?: .*)? $",
      ],
      sourceCommand:
        "jq -r '.tasks | to_entries | .[] | .key + \" = \" + .value' deno.json",
      "options": {
        "--prompt": "'deno task > '",
      },
      callback: "awk -F ' = ' '{ print $1 }'",
    },
    {
      name: "ollama run",
      patterns: [
        "^ollama run(?: .*)? $",
      ],
      sourceCommand: "ollama list | grep -v 'NAME' | awk -F ':' '{print $1}'",
      "options": {
        "--prompt": "'ollama run > '",
      },
      callback: "",
    },
    {
      name: "act run job",
      patterns: [
        "^act --job (?: .*)?",
      ],
      sourceCommand: "act --list | grep -v Stage | awk '{print $2}'",
      "options": {
        "--prompt": "'act --job > '",
      },
      callback: "",
    },
    {
      name: "ssh login",
      patterns: [
        "^ssh(?: .*)? $",
      ],
      sourceCommand:
        "cat $HOME/.ssh/*.conf | grep '^Host' | grep -v -E '(github\\.com|[bastion])' | awk '{print $2}'",
      "options": {
        "--prompt": "'ssh > ' ",
      },
      callback: "",
    },
    {
      name: "toggle active gcloud account",
      patterns: [
        "^gcloud config configurations activate(?: .*)?",
      ],
      sourceCommand: "gcloud config configurations list --format 'value(name)'",
      "options": {
        "--prompt": "'gcloud --project > '",
      },
      callback: "",
    },
  ],
}));
