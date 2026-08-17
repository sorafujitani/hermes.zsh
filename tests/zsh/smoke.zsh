#!/usr/bin/env zsh
set -eu

binary=${HERMES_BIN:?HERMES_BIN must point to the hermes executable}
stdout_file=$(mktemp)
stderr_file=$(mktemp)
trap 'rm -f "$stdout_file" "$stderr_file"' EXIT

"$binary" --help >"$stdout_file" 2>"$stderr_file"
[[ -s "$stdout_file" ]]
[[ ! -s "$stderr_file" ]]

PATH="${binary:h}:$PATH"
dummy-fzf-tab-widget() { : }
zle -N fzf-tab-complete dummy-fzf-tab-widget
fzf_tab_before=${widgets[fzf-tab-complete]}
source "${0:A:h:h:h}/hermes.zsh"
[[ $HERMES_BOOTSTRAPPED == 1 ]]
[[ -n $HERMES_SESSION_ID ]]
[[ ${widgets[fzf-tab-complete]} == $fzf_tab_before ]]
for function_name in hermes-server hermes-init hermes-ensure-loaded hermes-preload \
  hermes-register-lazy-widget hermes-register-lazy-widgets hermes-bind-default-keys \
  hermes-call-client-and-fallback hermes-history-hooks hermes-preprompt-hooks \
  hermes-lazy-widget-dispatch hermes-enable-sock; do
  (( $+functions[$function_name] ))
done
for widget in hermes-auto-snippet hermes-completion hermes-history-selection \
  hermes-insert-snippet hermes-snippet-next-placeholder hermes-ghq-cd; do
  [[ -n ${widgets[$widget]-} ]]
done
