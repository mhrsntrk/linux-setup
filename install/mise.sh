#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

source "${SCRIPT_DIR}/../setupLibrary.sh"

main() {
  load_config
  ensure_packages gpg software-properties-common wget

  if [[ ! -f /etc/apt/sources.list.d/jdxcode-ubuntu-mise-noble.sources ]] && [[ ! -f /etc/apt/sources.list.d/jdxcode-ubuntu-mise-noble.list ]]; then
    sudo add-apt-repository -y ppa:jdxcode/mise
    APT_UPDATED=false
  fi

  run_apt_update_once
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mise

  install -d -m 755 "$HOME/.config/mise"
  cat > "$HOME/.config/mise/config.toml" <<'EOF'
[tools]
node = "latest"
go = "latest"
python = "latest"

[settings]
experimental = true
EOF

mise install
  log 'mise and latest Node, Go, Python runtimes are installed.'
}

main "$@"
