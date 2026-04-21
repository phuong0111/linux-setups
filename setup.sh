#!/usr/bin/env bash
# Full environment setup (Terminal + Dev Stack)
set -eo pipefail

echo "🚀 Starting full environment setup..."

# Check if running on a Debian/Ubuntu system
if ! command -v apt &> /dev/null; then
    echo "❌ This script requires apt package manager (Debian/Ubuntu)"
    exit 1
fi

SUDO=$(command -v sudo &>/dev/null && echo "sudo" || echo "")

# Ensure non-interactive apt
export DEBIAN_FRONTEND=noninteractive

# 1. Base Tools & Terminal Dependencies
echo "📦 Updating package list and installing base tools..."
$SUDO apt update -y
$SUDO apt install -y --no-install-recommends \
  curl ca-certificates git gnupg lsb-release build-essential \
  zsh zsh-autosuggestions zsh-syntax-highlighting fonts-powerline

# 2. Oh My Zsh and Plugins
echo "🔧 Setting up Oh My Zsh and plugins..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "✅ Oh My Zsh already installed"
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]; then
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autocomplete" ]; then
    git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git "$ZSH_CUSTOM/plugins/zsh-autocomplete"
fi

# Backup existing .zshrc and update it
if [ -f "$HOME/.zshrc" ] && ! grep -q "zsh-autosuggestions" "$HOME/.zshrc" 2>/dev/null; then
    echo "💾 Updating .zshrc configuration..."
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
    sed -i 's/^plugins=(git)$/plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete)/' "$HOME/.zshrc"
    sed -i 's/^ZSH_THEME="robbyrussell"$/ZSH_THEME="agnoster"/' "$HOME/.zshrc"
fi

# 3. Docker
echo "🐳 Installing Docker..."
$SUDO apt install -y docker.io docker-compose
$SUDO systemctl enable --now docker
if ! id -nG "$USER" | grep -qw docker; then
  $SUDO usermod -aG docker "$USER"
fi

# 4. Node.js via nvm
echo "🟢 Installing nvm and Node 24..."
if [[ ! -d "$HOME/.nvm" ]]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install 24
nvm alias default 24
nvm use 24

# 5. uv (Python)
echo "🐍 Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

# 6. Apache & PHP
echo "🧱 Installing Apache2 & PHP..."
$SUDO apt install -y apache2 php libapache2-mod-php
$SUDO systemctl enable --now apache2

echo -e "\n✅ Setup complete!"
echo "🔎 Node: $(node -v)"
echo "🔎 uv:   $(uv --version)"
echo "🔎 PHP:  $(php -v | head -n1)"
echo "💡 Reminder: Change your default shell to zsh running 'chsh -s \$(which zsh)' if not done automatically."
echo "💡 Reminder: Run 'newgrp docker' or log out/in to use Docker without sudo."
