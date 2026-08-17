# Installation, migration, rollback, and removal

## Install from a release

Download `scripts/install.sh` from the same tagged source revision, inspect it,
then run it with the tag, for example `sh install.sh v1.0.0`. Add this loader:

```zsh
source "$HOME/.local/lib/hermes/hermes.zsh"
```

Hermes configuration uses `HERMES_*` environment variables, `hermes-*` widgets,
and declarative YAML exclusively. No JavaScript runtime is required or started.

The client performs exactly one serialized daemon-start retry. For environments
where a background process cannot be started, set `HERMES_DIRECT_FALLBACK=1`
to execute feature requests in the short-lived CLI process after that retry
fails. This degraded mode does not support daemon
lifecycle operations or cross-request caches and prints a diagnostic on stderr.

## Adopt Hermes

1. Create YAML configuration under `~/.config/hermes` or set
   `HERMES_HOME` explicitly.
2. Source the Hermes loader shown above and bind the desired `hermes-*` widgets.
3. Run `hermes server status` and open a nested shell. Both must report the same
   daemon PID.
4. Exercise snippet, completion, placeholder, ghq, and history bindings.

History starts in Hermes' SQLite database. NDJSON can use stdin/stdout, while
the compatible file-oriented formats use `--in` and `--out`:

```sh
hermes history export > hermes-history.jsonl
hermes history import < hermes-history.jsonl
hermes history export --format zsh --out zsh-history.txt
hermes history import --format zsh --in zsh-history.txt --dedupe strict
hermes history export --format atuin-json --out atuin.jsonl
```

Imports validate the complete input before opening a transaction. Existing
databases are never silently replaced. `--dry-run` validates without inserting;
`--dedupe strict` and `--dedupe loose` skip an already-present record ID. Fish
is an export format in v1; importing Fish YAML is intentionally unsupported.

## Upgrade and rollback

The installer fully extracts and verifies a versioned release directory before
atomically switching the `current` symlink. An interrupted download or extract
therefore leaves the active version untouched. After an upgrade, restart and
inspect the build identity with `hermes server status`. To roll back, run
`scripts/rollback.sh vPREVIOUS`, then `hermes server restart`. Installed release
directories are retained until removal; configuration and history are never
part of the switch. Protocol incompatibility is reported before feature work
runs.

## Remove

Run `scripts/uninstall.sh`. It stops the daemon and removes installed binaries
and shell files. Configuration and history are preserved deliberately. Remove
those user-owned files separately only after making any required backup.

## Optional dependencies

`fzf` is required for interactive selection and `ghq` for repository selection.

Hermes does not register or replace `fzf-tab-complete`. fzf-tab may continue to
own normal Zsh completion, while Hermes owns only keys explicitly bound to its
widgets. If both are wanted on Tab, choose the binding explicitly instead of
depending on plugin load order.
