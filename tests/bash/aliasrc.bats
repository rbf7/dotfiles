#!/usr/bin/env bats

load './test_helper.bash'

setup() {
  REPO_ROOT="$(repo_root)"
  require_command zsh
}

@test 'aliasrc ex() reports invalid file for missing path' {
  run zsh -c "source '$REPO_ROOT/aliasrc'; ex '/no/such/file.tar.gz'"

  [ "$status" -eq 0 ]
  [[ "$output" == *"is not a valid file"* ]]
}

@test 'aliasrc ex() reports unsupported archive extension' {
  local f
  f="${BATS_TEST_TMPDIR}/sample.unsupported"
  echo 'payload' >"$f"

  run zsh -c "source '$REPO_ROOT/aliasrc'; ex '$f'"

  [ "$status" -eq 0 ]
  [[ "$output" == *"cannot be extracted via ex()"* ]]
}

@test 'aliasrc defines safe file operation aliases' {
  run zsh -c "source '$REPO_ROOT/aliasrc'; alias rm; alias cp; alias mv"

  [ "$status" -eq 0 ]
  [[ "$output" == *"rm='rm -i'"* ]]
  [[ "$output" == *"cp='cp -i'"* ]]
  [[ "$output" == *"mv='mv -i'"* ]]
}