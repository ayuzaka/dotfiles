import { defineConfig } from "jsr:@yuki-yano/zeno";

export default defineConfig(() => ({
  snippets: [
    {
      name: "docker container exec",
      keyword: "dc-exec",
      snippet: "docker container exec -it",
    },
    {
      name: "devcontainer exec",
      keyword: "dcon-exec",
      snippet: "devcontainer exec --workspace-folder . /bin/bash -i",
    },
  ],
  completions: [
    {
      name: "gh pr checkout",
      patterns: [
        "^gh pr checkout(?: .*)? $",
      ],
      sourceCommand:
        "gh pr list --json number,title,author --jq '.[] | [.number, .title, .author.login] | @csv'",
      options: {
        "--height": "80%",
        "--print0": true,
        "--preview-window": "down",
        "--prompt": "'gh pr checkout > ' ",
      },
      callback: "awk -F ',' '{print $1}'",
    },
    {
      name: "tmux attach",
      patterns: [
        "^tmux a -t(?: .*)? $",
      ],
      sourceCommand: "tmux ls",
      options: {
        "--height": "80%",
        "--print0": true,
        "--preview-window": "down",
        "--prompt": "'tmux attach > ' ",
      },
      callback: "awk -F ':' '{print $1}'",
    },
    {
      name: "docker (running) container operation",
      patterns: [
        "^docker container exec -it(?: .*)? $",
        "^docker container stop(?: .*)? $",
      ],
      sourceCommand: "docker container ls --format '{{.Names}}'",
      options: {
        "--prompt": "'docker container > ' ",
      },
      callback: "",
    },
    {
      name: "docker container operation",
      patterns: [
        "^docker container rm(?: .*)? $",
      ],
      sourceCommand: "docker container ls -a --format '{{.Names}}'",
      options: {
        "--prompt": "'docker container > ' ",
      },
      callback: "",
    },
    {
      name: "docker image operation",
      patterns: [
        "^docker image rm(?: .*)? $",
      ],
      sourceCommand:
        "docker image ls --format '{{.Repository}}:{{.Tag}}:{{.ID}}'",
      options: {
        "--prompt": "'docker image > ' ",
      },
      callback: "awk -F ':' '{print $3}'",
    },
  ],
}));
