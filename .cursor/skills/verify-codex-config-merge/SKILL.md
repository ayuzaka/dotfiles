---
name: verify-codex-config-merge
description: Prove that merge-codex-config applies managed Codex settings while keeping unmanaged keys and Codex-owned marketplace state. Use when a change touches scripts/merge-codex-config, merge_tables, remove_system_managed_settings, or the merge sequence in run.
---

# Verify the Codex config merge

Managed settings in `extras/codex/config.toml` must replace the current Codex config, and keys Codex owns itself must survive. A break overwrites `tui.model_availability_nux` or `marketplaces.*.last_updated` / `last_revision`, or drops project trust the repo does not manage. The user then loses local Codex state or keeps a stale managed setting.

The check is a proptest over the real `remove_system_managed_settings` and `merge_tables`, called in that order, which is the order `run` uses. It is not a hand model of the merge. Kani does not run `toml_edit`'s parser and owned strings at a useful bound, and a TLA+ model would not execute this code. proptest `1.12.0` does, and it shrinks a failure to a short TOML pair.

## When a change needs this check

Run it when a diff touches any of these in `scripts/merge-codex-config/src/main.rs`:

- `MARKETPLACE_STATE_KEYS`
- `remove_system_managed_settings`
- `merge_tables`
- `items_are_equal`
- the strip-then-merge sequence in `load_desired_config` and `run`

A change that only edits tests, the CLI help text, or another dotfile does not need this check. Symlink refusal and the `0600` mode live in `validate_target` and `write_atomically`. This check does not cover them.

## Run

From the checkout, with a Rust that accepts `edition = "2024"` (the repo sets `rust = "latest"`; Rust 1.83 fails the manifest):

```sh
cargo test --manifest-path scripts/merge-codex-config/Cargo.toml -- --test-threads=8 merge_applies_managed_settings_and_keeps_unmanaged_state
```

The command replays `scripts/merge-codex-config/proptest-regressions/main.txt` and then 64 new cases. A passing run prints `ok` for that test. The whole `cargo test` for this package also runs `preserves_unmanaged_projects_and_codex_state`, which is one fixed example of the same promise.

## What a failure means

Each case builds two TOML documents, then forces these leaves before merging:

- `model` is `from-current` in the current file and `from-desired` in the desired file. The merge must apply `from-desired`.
- `tui.model_availability_nux`, `marketplaces.example.last_updated`, and `marketplaces.example.last_revision` are planted on both sides. After the strip, the merge must keep the current strings.
- `marketplaces.example.source` must become `https://desired.example/managed.git`.

The rest of the documents are compared the same way: a table merges with a table; any other desired item replaces the current item; current keys the stripped desired document does not mention stay; the merge adds no third key.

Read the panic text this way:

- `was overwritten or dropped`, `was not applied`, `unmanaged key dropped`, `unmanaged key changed`, or `merge invented key` is a product failure. The minimal `current_toml` and `desired_toml` are the counterexample. Say which planted key moved.
- `merged item must parse as TOML` is an oracle failure. The checker could not read an item back. Do not treat that as a broken merge unless the merged document itself is no longer TOML.

A scratch change that replaced a nested table instead of merging it failed this test. The smallest input was two empty documents. After the planted keys were added, `tui.model_availability_nux` was `None` instead of `from-current`, because the empty stripped `tui` table replaced the current `tui` table. That edit was reverted. The test passed again afterward.

## Scope

The generator builds tables up to depth 3, at most 8 nodes, and at most 3 children. Keys are `last_updated`, `last_revision`, `model_availability_nux`, `source`, `model`, `tui`, `marketplaces`, or `[a-c]{1,3}`. Leaves are bools, integers from -5 to 4, strings of up to 4 letters, or arrays of up to 2 such strings. 64 cases run per invocation, plus the saved regression.

`toml_edit`'s `is_table()` decides what merges. Inline tables and arrays of tables are replaced whole. The check does not execute `run`, so it does not cover CLI parsing, symlink refusal, atomic replace, mode `0600`, comment layout, or the mise task that launches the binary. A pass is a pass of this model of the merge functions, not of every Codex config on disk.

## Keeping it in step

Confirmed against commit `b005bcfa01577e6ab8acd4e19ec40b0e7e8e5b8b`. The product functions above were unchanged in that commit; the property test was added after `main` in the same file. Move this commit forward only after you re-run the command and confirm the oracle still describes the functions at the new commit. If those functions differ from this commit and the check has not been re-run, say the verification is stale instead of reporting a pass.
