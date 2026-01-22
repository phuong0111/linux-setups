#!/usr/bin/env bash
#
# Dev Stack Setup Script (Docker, Node via nvm, uv, Apache2, PHP)
# Tested on Ubuntu/Debian. Run with:  bash setup_dev_stack.sh
#

set -euo pipefail

echo "🚀 Starting dev stack setup..."

#---------------------------
# Pre-flight checks
#---------------------------
if ! command -v apt &>/dev/null; then
  echo "❌ This script requires apt (Debian/Ubuntu)."
  exit 1
fi

if [[ $(id -u) -ne 0 ]]; then
  if ! command -v sudo &>/dev/null; then
    echo "❌ Please run as root or install sudo."
    exit 1
  fi
  SUDO="sudo"
else
  SUDO=""
fi

NEED_RELOGIN=0
SHELL_RC_CANDIDATES=(~/.zshrc ~/.bashrc ~/.profile)
CURRENT_SHELL="$(basename "${SHELL:-sh}")"

# Ensure non-interactive apt
export DEBIAN_FRONTEND=noninteractive

#---------------------------
# Update apt and base tools
#---------------------------
echo "📦 Updating package list..."
$SUDO apt update -y

echo "📦 Installing base dependencies..."
$SUDO apt install -y --no-install-recommends \
  curl ca-certificates git gnupg lsb-release build-essential

#---------------------------
# Docker & docker-compose
#---------------------------
echo "🐳 Installing Docker & docker-compose..."
$SUDO apt install -y docker.io docker-compose

echo "🔧 Enabling and starting Docker..."
$SUDO systemctl enable --now docker

# Add current user to docker group (so you can run without sudo)
if ! id -nG "$USER" | grep -qw docker; then
  echo "👤 Adding user '$USER' to docker group..."
  $SUDO usermod -aG docker "$USER"
  NEED_RELOGIN=1
else
  echo "✅ '$USER' already in docker group"
fi

#---------------------------
# Node.js via nvm (v24)
#---------------------------
echo "🟢 Installing nvm (Node Version Manager)..."
if [[ ! -d "$HOME/.nvm" ]]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
else
  echo "✅ nvm already installed"
fi

# Source nvm in current shell session
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  # shellcheck disable=SC1091
  . "$HOME/.nvm/nvm.sh"
elif [[ -s "/usr/share/nvm/nvm.sh" ]]; then
  # Fallback if installed system-wide
  # shellcheck disable=SC1091
  . "/usr/share/nvm/nvm.sh"
else
  # Ensure future shells load nvm
  for rc in "${SHELL_RC_CANDIDATES[@]}"; do
    if [[ -f "$rc" ]] && ! grep -q 'NVM_DIR' "$rc"; then
      echo 'export NVM_DIR="$HOME/.nvm"' >> "$rc"
      echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> "$rc"
    fi
  done
  # Try again for current session if it just got installed
  if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    # shellcheck disable=SC1091
    . "$HOME/.nvm/nvm.sh"
  fi
fi

echo "⬇️  Installing Node 24 via nvm..."
if command -v nvm &>/dev/null; then
  nvm install 24
  nvm alias default 24
  nvm use 24
  echo "🔎 Node version: $(node -v || true)"
  echo "🔎 npm version:  $(npm -v || true)"
else
  echo "⚠️  nvm not found in current session; Node 24 will be available in new shells after login."
fi

#---------------------------
# uv (Python package manager)
#---------------------------
echo "🐍 Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh

# TEMPORARY FIX: Turn off 'unbound variable' check so we can source rc files safely
set +u 

case "$CURRENT_SHELL" in
  zsh)
    [[ -f "$HOME/.zshrc" ]] && . "$HOME/.zshrc" || true
    ;;
  bash)
    [[ -f "$HOME/.bashrc" ]] && . "$HOME/.bashrc" || true
    ;;
  *)
    [[ -f "$HOME/.profile" ]] && . "$HOME/.profile" || true
    ;;
esac

# Turn strict mode back ON
set -u

echo "🔎 uv version: $(command -v uv >/dev/null 2>&1 && uv --version || echo 'uv will be on PATH in a new shell')"

#---------------------------
# Apache2 & PHP
#---------------------------
echo "🧱 Installing Apache2 & PHP..."
$SUDO apt install -y apache2 php libapache2-mod-php

echo "🔧 Enabling and starting Apache2..."
$SUDO systemctl enable --now apache2

# Optional: open firewall, if ufw is present and active
if command -v ufw &>/dev/null; then
  if ufw status | grep -q "Status: active"; then
    echo "🌐 Allowing Apache through UFW..."
    $SUDO ufw allow 'Apache Full' || true
  fi
fi

#---------------------------
# Summary
#---------------------------
echo ""
echo "✅ Setup complete!"
echo "   • Docker:      $($SUDO systemctl is-active docker || true), compose: $(docker-compose --version 2>/dev/null || echo 'not found')"
echo "   • Node/npm:    $(node -v 2>/dev/null || echo 'not found') / $(npm -v 2>/dev/null || echo 'not found')"
echo "   • uv:          $(command -v uv >/dev/null 2>&1 && uv --version || echo 'not found (will appear after new shell)')"
echo "   • Apache/PHP:  $($SUDO systemctl is-active apache2 || true), PHP: $(php -v 2>/dev/null | head -n1 || echo 'not found')"
if [[ $NEED_RELOGIN -eq 1 ]]; then
  echo "ℹ️  Note: You were added to the 'docker' group. Please log out and back in (or run 'newgrp docker') to use Docker without sudo."
fi
echo "🎉 All done."
