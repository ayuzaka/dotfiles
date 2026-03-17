- Do not hardcode context into shell commands; pass it via environment variables.
- Enclose all environment variables in double quotes.
- Specify the workflow run name using the `run-name` key.
- Utilize the `GITHUB_OUTPUT` environment variable for data sharing between steps.
- Use the `GITHUB_ENV` environment variable when referencing the same value across different multiple steps.
- Set a timeout for all workflows.
- When using publicly exposed actions, please specify the commit hash of the latest available version

最新ハッシュの取得手順:

```sh
# 1. 最新リリースのタグ名を確認する
gh release list -R <owner>/<repo> --limit 1 --json tagName

# 2. タグに対応するコミットハッシュを取得する（アノテーテッドタグにも対応）
gh api repos/<owner>/<repo>/commits/<tagName> --jq '.sha'
```

Example:

```yaml
steps:
  - name: Checkout
    uses: actions/checkout@8e8c483db84b4bee98b60c0593521ed34d9990e8 # v6.0.1
```

- Specifying the default shell ensures a shell is set for all steps, thereby enabling pipe error detection.

Example: 

```yaml
defaults:
  run:
    shell: bash # ワークフローで使うシェルをまとめて指定する
```

- Control workflow job concurrency by specifying `concurrency.cancel-in-progress: true`.

Example:

```yaml
concurrency:
  group: <Concurrencyグループ>
  cancel-in-progress: true
```

- Use [actionlint](https://github.com/rhysd/actionlint) and [zizmor](https://docs.zizmor.sh/) to check for errors and warnings. Address any issues you find to the best of your ability.
