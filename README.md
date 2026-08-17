# hermes.zsh

Hermes is an independent Rust-native shell workflow suite for Zsh. It combines
interactive snippets, completion, repository navigation, and durable history
behind a fast per-user daemon.

The v1 implementation includes a framed versioned protocol, a deterministic
per-user daemon, YAML configuration, snippets/placeholders/preprompt, completion
and built-in Git/ghq sources, the Zsh adapter, and transactional Smart History.

## Zsh setup

```zsh
source "$HOME/.local/lib/hermes/hermes.zsh"
hermes-bind-default-keys
```

Hermes exposes only `hermes`, `hermesd`, `hermes-*` widgets, and `HERMES_*`
settings. `fzf` is needed for interactive pickers and `ghq` for the repository
widget. Hermes itself has no JavaScript runtime dependency.

## Build and check

```sh
cargo build --release
cargo fmt --all -- --check
cargo clippy --workspace --all-targets -- -D warnings
cargo test --workspace
```

The minimum supported Rust version is 1.85. Hermes targets current macOS and
Linux runners. Zsh 5.8 or newer is the v1 shell target.

## Daemon control

```sh
hermes server start
hermes server status
hermes server restart
hermes server stop
```

The socket is located under `$HERMES_RUNTIME_DIR` when set, then
`$XDG_RUNTIME_DIR/hermes`, otherwise a user-owned `/tmp/hermes-UID` directory.
Hermes rejects runtime directories owned by another user or accessible to group
or other users.

Hermes reads YAML configuration from `$HERMES_HOME`, `$HERMES_CONFIG`, project
`.hermes` directories, and standard XDG locations. Configuration parsing,
merging, caching, snippets, completion, and history are implemented in Rust.

See [the architecture](docs/architecture.md) and [the Hermes interface
contract](spec/manifest.json).

Installation, migration, upgrade, rollback, and removal are documented in the
[migration guide](docs/migration.md). Reproducible performance definitions and
budgets live in [performance-budgets.json](spec/performance-budgets.json).
