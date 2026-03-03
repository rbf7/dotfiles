#!/usr/bin/env bash

set -Eeuo pipefail

repo_root() {
  cd "${BATS_TEST_DIRNAME}/../.." && pwd -P
}

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    skip "Required command not found: $cmd"
  fi
}

make_stub_cmd() {
  local bindir="$1"
  local name="$2"
  local body="${3:-exit 0}"

  mkdir -p "$bindir"
  cat >"$bindir/$name" <<STUB
#!/usr/bin/env bash
set -Eeuo pipefail
$body
STUB
  chmod +x "$bindir/$name"
}

seed_install_env() {
  local home_dir="$1"
  local bin_dir="$2"

  mkdir -p "$home_dir/.zplug"
  : >"$home_dir/.zplug/init.zsh"
  : >"$home_dir/.zplug/packages.zsh"

  make_stub_cmd "$bin_dir" zsh 'if [[ "${1:-}" == "--version" ]]; then echo "zsh 5.9"; fi; exit 0'
  make_stub_cmd "$bin_dir" autojump 'exit 0'

  # Optional tools only need command discovery to pass.
  make_stub_cmd "$bin_dir" git 'exit 0'
  make_stub_cmd "$bin_dir" docker 'exit 0'
  make_stub_cmd "$bin_dir" node 'echo v20.0.0; exit 0'
  make_stub_cmd "$bin_dir" python3 'echo Python 3.11.0; exit 0'
  make_stub_cmd "$bin_dir" terraform 'echo Terraform v1.8.0; exit 0'
  make_stub_cmd "$bin_dir" go 'echo go version go1.22 linux/amd64; exit 0'
  make_stub_cmd "$bin_dir" rustc 'echo rustc 1.77.0; exit 0'
  make_stub_cmd "$bin_dir" ruby 'echo ruby 3.2.0; exit 0'
  make_stub_cmd "$bin_dir" php 'echo PHP 8.3.0; exit 0'
  make_stub_cmd "$bin_dir" java 'echo openjdk version "21"; exit 0'
}