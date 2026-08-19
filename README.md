# hermes.zsh

Hermes is an independent Rust-native shell workflow suite for Zsh. It combines
interactive snippets, completion, repository navigation, and durable history
behind a fast per-user daemon.

The v1 implementation includes a framed versioned protocol, a deterministic
per-user daemon, YAML configuration, snippets/placeholders/preprompt, completion
and built-in Git/ghq sources, the Zsh adapter, and transactional Smart History.

## Installation

### Homebrew

The Formula is maintained in the [`sorafujitani/homebrew-tap`](https://github.com/sorafujitani/homebrew-tap) repository:

```sh
brew tap sorafujitani/tap
brew install hermes
```

The Formula installs `hermes`, `hermesd`, the Zsh integration, and the runtime
dependencies `fzf` and `ghq`. It prints the loader line after installation.

### Nix

The flake exposes a package containing Hermes and the Zsh integration:

```sh
nix profile add github:sorafujitani/hermes.zsh#hermes
```

Add the loader to `.zshrc` using the default Nix profile:

```zsh
source "$HOME/.nix-profile/share/hermes/hermes.zsh"
hermes-bind-default-keys
```

For development, use the locked Nix tooling environment instead:

```sh
nix develop
cargo test --workspace
```

The Nix package is available as `.#hermes`; `.#hermes-core` is retained as an
alias. Install `fzf` and `ghq` separately when they are not already available.
Keeping those tools outside the Hermes profile avoids collisions with Home
Manager and existing Nix profiles. The locked Nixpkgs input currently targets
Apple Silicon macOS and Linux; Homebrew remains the installation path for Intel
macOS.

### Build from source

If neither package manager is available, build the workspace directly:

```sh
cargo build --release --bins
```

Then source `hermes.zsh` from the checkout. It adds the local
`target/release` directory to the Zsh path automatically.

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
