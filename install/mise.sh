#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

source "${SCRIPT_DIR}/../setupLibrary.sh"

main() {
  load_config
  ensure_packages curl

  if ! command -v mise &>/dev/null; then
    curl https://mise.run | sh
  fi

  install -d -m 755 "$HOME/.config/mise"
  cat > "$HOME/.config/mise/config.toml" <<'EOF'
[tools]
node = "latest"
go = "latest"
python = "latest"
java = "latest"
maven = "latest"
"npm:opencode" = "latest"

[settings]
experimental = true
EOF

  "$HOME/.local/bin/mise" trust "$HOME/.config/mise/config.toml"
  "$HOME/.local/bin/mise" install
  "$HOME/.local/bin/mise" reshim
  log 'mise and tools (Node, Go, Python, Java, Maven, opencode) are installed.'
}

main "$@"
