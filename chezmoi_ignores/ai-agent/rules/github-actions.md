- When using publicly exposed actions, please specify the commit hash of the latest available version

Example:

```yaml
steps:
  - name: Checkout
    uses: actions/checkout@8e8c483db84b4bee98b60c0593521ed34d9990e8 # v6.0.1
```

- Use [actionlint](https://github.com/rhysd/actionlint) and [zizmor](https://docs.zizmor.sh/) to check for errors and warnings. Address any issues you find to the best of your ability.
