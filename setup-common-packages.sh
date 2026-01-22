#!/usr/bin/env bash
# Dev Stack Setup Script (Docker, Node via nvm, uv, Apache2, PHP)
set -euo pipefail

echo "🚀 Starting dev stack setup..."

# Ensure non-interactive apt
export DEBIAN_FRONTEND=noninteractive
SUDO=$(command -v sudo &>/dev/null && echo "sudo" || echo "")

# 1. Base Tools
echo "📦 Updating package list and installing base tools..."
$SUDO apt update -y
$SUDO apt install -y --no-install-recommends \
  curl ca-certificates git gnupg lsb-release build-essential

# 2. Docker
echo "🐳 Installing Docker..."
$SUDO apt install -y docker.io docker-compose
$SUDO systemctl enable --now docker
if ! id -nG "$USER" | grep -qw docker; then
  $SUDO usermod -aG docker "$USER"
fi

# 3. Node.js via nvm
echo "🟢 Installing nvm and Node 24..."
if [[ ! -d "$HOME/.nvm" ]]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

# MANUALLY LOAD NVM (Crucial: This avoids the Zsh error)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install 24
nvm alias default 24
nvm use 24

# 4. uv (Python)
echo "🐍 Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
# MANUALLY UPDATE PATH (Crucial: This avoids the Zsh error)
export PATH="$HOME/.local/bin:$PATH"

# 5. Apache & PHP
echo "🧱 Installing Apache2 & PHP..."
$SUDO apt install -y apache2 php libapache2-mod-php
$SUDO systemctl enable --now apache2

echo -e "\n✅ Setup complete!"
echo "🔎 Node: $(node -v)"
echo "🔎 uv:   $(uv --version)"
echo "🔎 PHP:  $(php -v | head -n1)"
echo "💡 Reminder: Run 'newgrp docker' or log out/in to use Docker without sudo."
