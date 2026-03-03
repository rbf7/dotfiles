#!/usr/bin/env bats

load './test_helper.bash'

setup() {
  REPO_ROOT="$(repo_root)"
  TEST_HOME="${BATS_TEST_TMPDIR}/home"
  TEST_BIN="${BATS_TEST_TMPDIR}/bin"

  mkdir -p "$TEST_HOME" "$TEST_BIN"
  seed_install_env "$TEST_HOME" "$TEST_BIN"
}

run_installer() {
  run env \
    HOME="$TEST_HOME" \
    SHELL="$TEST_BIN/zsh" \
    PATH="$TEST_BIN:$PATH" \
    bash "$REPO_ROOT/install.sh"
}

@test 'install.sh links .zshrc and aliasrc into HOME' {
  run_installer

  [ "$status" -eq 0 ]
  [ -L "$TEST_HOME/.zshrc" ]
  [ -L "$TEST_HOME/aliasrc" ]

  [ "$(readlink "$TEST_HOME/.zshrc")" = "$REPO_ROOT/.zshrc" ]
  [ "$(readlink "$TEST_HOME/aliasrc")" = "$REPO_ROOT/aliasrc" ]
}

@test 'install.sh backs up existing regular files before linking' {
  echo 'old zshrc' >"$TEST_HOME/.zshrc"
  echo 'old alias' >"$TEST_HOME/aliasrc"

  run_installer

  [ "$status" -eq 0 ]
  compgen -G "$TEST_HOME/.zshrc.backup.*" >/dev/null
  compgen -G "$TEST_HOME/aliasrc.backup.*" >/dev/null
  [ -L "$TEST_HOME/.zshrc" ]
  [ -L "$TEST_HOME/aliasrc" ]
}

@test 'install.sh does not back up existing symlinks' {
  ln -s "$REPO_ROOT/.zshrc" "$TEST_HOME/.zshrc"
  ln -s "$REPO_ROOT/aliasrc" "$TEST_HOME/aliasrc"

  run_installer

  [ "$status" -eq 0 ]
  ! compgen -G "$TEST_HOME/.zshrc.backup.*" >/dev/null
  ! compgen -G "$TEST_HOME/aliasrc.backup.*" >/dev/null
}

@test 'install.sh ignores whitespace-only packages.zsh entries' {
  printf '   \n\t\n\n' >"$TEST_HOME/.zplug/packages.zsh"

  run_installer

  [ "$status" -eq 0 ]
  [ -s "$TEST_HOME/.zplug/packages.zsh" ]
}