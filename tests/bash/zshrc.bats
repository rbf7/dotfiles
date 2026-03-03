#!/usr/bin/env bats

load './test_helper.bash'

setup() {
  REPO_ROOT="$(repo_root)"
  require_command zsh

  TEST_HOME="${BATS_TEST_TMPDIR}/home-zsh"
  TEST_BIN="${TEST_HOME}/bin"
  mkdir -p "$TEST_HOME/.zplug" "$TEST_BIN"

  cat >"$TEST_HOME/.zplug/init.zsh" <<'ZPLUG'
# Minimal zplug shim for tests.
zplug() { return 0; }
ZPLUG
}

@test '.zshrc _check_zplug resolves HOME init path first' {
  run env HOME="$TEST_HOME" zsh -c "source '$REPO_ROOT/.zshrc' >/dev/null 2>&1; _check_zplug; printf '%s' \"\$ZPLUG_INIT_PATH\""

  [ "$status" -eq 0 ]
  [ "$output" = "$TEST_HOME/.zplug/init.zsh" ]
}

@test '.zshrc does not hard-fail when TERM_PROGRAM=vscode and code is missing' {
  run env HOME="$TEST_HOME" TERM_PROGRAM=vscode PATH="/usr/bin:/bin" zsh -c "source '$REPO_ROOT/.zshrc' >/dev/null 2>&1"

  [ "$status" -eq 0 ]
}

@test '.zshrc does not hard-fail when fzf is missing' {
  run env HOME="$TEST_HOME" PATH="/usr/bin:/bin" zsh -c "source '$REPO_ROOT/.zshrc' >/dev/null 2>&1"

  [ "$status" -eq 0 ]
}

@test '.zshrc binds Ctrl+Space to fzf-history-widget when fzf exists' {
  make_stub_cmd "$TEST_BIN" fzf 'cat | head -n 1'

  run env HOME="$TEST_HOME" PATH="$TEST_BIN:/usr/bin:/bin" zsh -ic "source '$REPO_ROOT/.zshrc' >/dev/null 2>&1; bindkey '^ '"

  [ "$status" -eq 0 ]
  [[ "$output" == *"fzf-history-widget"* ]]
}

@test '.zshrc keeps Ctrl+F bound to autosuggest-accept' {
  run env HOME="$TEST_HOME" PATH="/usr/bin:/bin" zsh -ic "source '$REPO_ROOT/.zshrc' >/dev/null 2>&1; bindkey '^F'"

  [ "$status" -eq 0 ]
  [[ "$output" == *"autosuggest-accept"* ]]
}