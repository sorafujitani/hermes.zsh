if [[ -n ${HERMES_BOOTSTRAPPED-} ]]; then
  return 0
fi

() {
  emulate -L zsh
  local root=${${(%):-%x}:A:h:h:h}
  local widgets_dir=$root/shells/zsh/widgets
  local completions_dir=$root/shells/zsh/completions
  local widget

  export HERMES_ROOT=${HERMES_ROOT:-$root}
  export HERMES_SESSION_ID=${HERMES_SESSION_ID:-"zsh-${EPOCHREALTIME//./}-${$}-${RANDOM}"}
  export HERMES_HISTORY_SESSION_ID=${HERMES_HISTORY_SESSION_ID:-$HERMES_SESSION_ID}
  export HERMES_ENABLE=${HERMES_ENABLE:-1}

  if (( ${path[(I)$HERMES_ROOT/target/release]} == 0 )); then
    path+=("$HERMES_ROOT/target/release")
  fi
  if (( ${fpath[(I)$widgets_dir]} == 0 )); then
    fpath+=("$widgets_dir")
  fi
  if (( ${fpath[(I)$completions_dir]} == 0 )); then
    fpath+=("$completions_dir")
  fi

  typeset -ga HERMES_WIDGETS=(
    hermes-auto-snippet hermes-auto-snippet-and-accept-line hermes-completion
    hermes-ghq-cd hermes-history-selection hermes-insert-snippet
    hermes-insert-space hermes-preprompt hermes-preprompt-snippet
    hermes-smart-history-selection hermes-snippet-next-placeholder
    hermes-toggle-auto-snippet
  )

  for widget in $HERMES_WIDGETS; do
    autoload -Uz -- "$widget"
    zle -N -- "$widget"
  done

  hermes-server() { command hermes server "$@" }
  hermes-init() {
    [[ -n ${HERMES_LOADED-} ]] && return 0
    if [[ ${HERMES_DISABLE_DAEMON-} == (1|true) ]]; then
      export HERMES_LOADED=1
      return 0
    fi
    command hermes server start >/dev/null || return
    export HERMES_LOADED=1
  }
  hermes-ensure-loaded() { hermes-init "$@" }
  hermes-preload() { command hermes server start >/dev/null 2>&1 &! }
  hermes-enable-sock() { command hermes server start >/dev/null }
  hermes-call-client-and-fallback() { command hermes "$@" }
  hermes-register-lazy-widget() {
    local widget=$1
    autoload -Uz -- "$widget"
    zle -N -- "$widget"
  }
  hermes-register-lazy-widgets() {
    local widget
    for widget in "$@"; do hermes-register-lazy-widget "$widget"; done
  }
  hermes-run-lazy-fallback() { zle ${1:-expand-or-complete} }
  hermes-lazy-widget-dispatch() { zle "$@" }
  hermes-history-hooks() {
    emulate -L zsh
    autoload -Uz add-zsh-hook
    hermes-history-preexec() {
      [[ -n ${HERMES_HISTORY_SUPPRESS-} ]] && return 0
      typeset -g HERMES_HISTORY_LAST_COMMAND=$1
      typeset -g HERMES_HISTORY_LAST_PWD=$PWD
      (( ! $+modules[zsh/datetime] )) && zmodload zsh/datetime
      typeset -g HERMES_HISTORY_LAST_STARTED_AT=$EPOCHREALTIME
    }
    hermes-history-precmd() {
      local exit_status=$?
      [[ -n ${HERMES_HISTORY_LAST_COMMAND-} ]] || return 0
      [[ -n ${HERMES_HISTORY_SUPPRESS-} ]] && return 0
      typeset -g HERMES_HISTORY_SUPPRESS=1
      local started_at=${HERMES_HISTORY_LAST_STARTED_AT-}
      local finished_at=$EPOCHREALTIME
      local seconds=${started_at%%.*}
      local fraction=${started_at#*.}
      fraction=${fraction:0:3}
      fraction=${(l:3::0:)fraction}
      local iso=$(command date -u -r "${seconds:-$EPOCHSECONDS}" '+%Y-%m-%dT%H:%M:%S' 2>/dev/null)
      [[ -n $iso ]] || iso=$(command date -u -d "@${seconds:-$EPOCHSECONDS}" '+%Y-%m-%dT%H:%M:%S' 2>/dev/null)
      local -F 10 duration=$(( (finished_at - started_at) * 1000 ))
      (( duration < 0 )) && duration=0
      command hermes history log "$HERMES_HISTORY_LAST_COMMAND" \
        --cwd "${HERMES_HISTORY_LAST_PWD:-$PWD}" --exit-status "$exit_status" \
        --session "$HERMES_HISTORY_SESSION_ID" --shell "${ZSH_NAME:-zsh}" \
        --host "${HOST:-}" --user "${USER:-}" --ts "${iso}.${fraction}Z" \
        --duration-ms "${duration%.*}" \
        >/dev/null 2>&1 &!
      unset HERMES_HISTORY_SUPPRESS HERMES_HISTORY_LAST_COMMAND HERMES_HISTORY_LAST_PWD HERMES_HISTORY_LAST_STARTED_AT
    }
    add-zsh-hook -d preexec hermes-history-preexec 2>/dev/null
    add-zsh-hook -d precmd hermes-history-precmd 2>/dev/null
    add-zsh-hook preexec hermes-history-preexec
    add-zsh-hook precmd hermes-history-precmd
    typeset -g HERMES_HISTORY_HOOK_INITIALIZED=1
  }
  hermes-preprompt-hooks() {
    emulate -L zsh
    [[ ${HERMES_PREPROMPT_HOOK_INITIALIZED-} == 1 ]] && return 0
    autoload -Uz add-zle-hook-widget
    hermes-preprompt-line-init() {
      [[ -n ${HERMES_PREPROMPT_BUFFER-} && -z $BUFFER ]] || return 0
      BUFFER=$HERMES_PREPROMPT_BUFFER
      CURSOR=${HERMES_PREPROMPT_CURSOR:-${#BUFFER}}
    }
    add-zle-hook-widget line-init hermes-preprompt-line-init
    typeset -g HERMES_PREPROMPT_HOOK_INITIALIZED=1
  }

  hermes-bind-default-keys() {
    bindkey ' ' hermes-auto-snippet
    bindkey '^M' hermes-auto-snippet-and-accept-line
    bindkey '^I' hermes-completion
    bindkey '^R' hermes-history-selection
    bindkey '^X^S' hermes-insert-snippet
    bindkey '^X^G' hermes-ghq-cd
  }
  hermes-history-hooks
  [[ -o interactive ]] && hermes-preprompt-hooks
  if (( $+functions[compdef] )); then
    autoload -Uz _hermes
    compdef _hermes hermes hermesd
  fi

  export HERMES_BOOTSTRAPPED=1
}
