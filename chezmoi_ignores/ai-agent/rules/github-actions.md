- Do not hardcode context into shell commands; pass it via environment variables.
- Enclose all environment variables in double quotes.
- Specify the workflow run name using the `run-name` key.
- Utilize the `GITHUB_OUTPUT` environment variable for data sharing between steps.
- Use the `GITHUB_ENV` environment variable when referencing the same value across different multiple steps.
- Set a timeout for all workflows.
- When using publicly exposed actions, pin each `uses:` reference to a full-length commit SHA with a trailing version comment. Use [pinact](https://github.com/suzuki-shunsuke/pinact) to apply or refresh pins instead of resolving hashes manually (for example with `gh`).

pinact の利用:

```sh
# リポジトリルートで実行（既定の対象: .github/workflows/*.yml など）
pinact run

# アクションを最新に更新しつつコミットハッシュへ固定する
pinact run -u
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
