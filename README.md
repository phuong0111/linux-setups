Perfect — here’s the **updated full README.md** that includes both scripts:

---

````markdown
# 🧠 Fascinating Linux Setup Scripts

A collection of powerful setup scripts for Debian/Ubuntu systems — from **terminal customization** to **developer stack installation** — all in one place.  
Get your environment up and running beautifully in just a few commands.

---

## 🚀 Quick Start

### 🖥️ Terminal Setup (Zsh + Plugins)

```bash
wget https://raw.githubusercontent.com/phuong0111/linux-setups/main/setup-terminal.sh
chmod +x setup-terminal.sh
./setup-terminal.sh
chsh -s $(which zsh)
zsh
source ~/.zshrc
````

> 💡 After installation, your terminal will open in **Zsh** with:
>
> * Auto-suggestions
> * Auto-completion
> * Syntax highlighting
> * A modern Agnoster theme with Powerline fonts

---

### 🧰 Common Developer Stack Setup

This script installs **Docker**, **Node.js (via nvm)**, **uv**, **Apache2**, and **PHP** — the essentials for full-stack web development.

```bash
wget https://raw.githubusercontent.com/phuong0111/linux-setups/main/setup-common-packages.sh
chmod +x setup-common-packages.sh
./setup-common-packages.sh
```

> 💡 This script sets up everything you need for web, AI, or backend development.

---

## ✨ Features

### 🧩 setup-terminal.sh

* Installs **Oh My Zsh** automatically
* Adds essential **Zsh plugins**:

  * `zsh-autosuggestions`
  * `zsh-syntax-highlighting`
  * `fast-syntax-highlighting`
  * `zsh-autocomplete`
* Configures **Agnoster** theme with Powerline fonts
* Safely updates `.zshrc` with backup
* Detects and skips existing installations

### ⚙️ setup-common-packages.sh

* 📦 Updates apt repositories
* 🐳 Installs **Docker** and **docker-compose**, and adds current user to `docker` group
* 🟢 Installs **Node.js 24** and **npm 11** using **nvm**
* 🐍 Installs **uv** (Python package manager from Astral)
* 🧱 Installs **Apache2** and **PHP** with `libapache2-mod-php`
* 🌐 Optionally enables **UFW** firewall rules for Apache
* 🧩 Automatically sources environment files for `nvm` and `uv`

---

## 📋 Requirements

| Requirement        | Description                                 |
| ------------------ | ------------------------------------------- |
| 🖥️ **OS**         | Debian / Ubuntu (requires `apt`)            |
| 🔑 **Permissions** | `sudo` privileges for installing packages   |
| 🌐 **Internet**    | Active connection for downloads and cloning |
| 💾 **Disk space**  | ~1–2 GB recommended                         |

---

## 🧭 Customization

### Change Zsh Theme

Edit in `~/.zshrc`:

```bash
ZSH_THEME="agnoster"
```

Replace with any [Oh My Zsh theme](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes).

### Add / Remove Zsh Plugins

```bash
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete)
```

---

## 🧼 Uninstallation

### Remove Terminal Customization

```bash
chsh -s $(which bash)
rm -rf ~/.oh-my-zsh ~/.zshrc ~/.zshrc.backup
```

### Remove Common Packages (optional)

```bash
sudo apt remove --purge docker.io docker-compose apache2 php -y
sudo rm -rf ~/.nvm ~/.uv
```

---

## 🧑‍💻 Author

**Phương Đinh Đoàn Xuân**
🔗 [github.com/phuong0111](https://github.com/phuong0111)

---

## 📜 License

MIT License © 2025 Phương Đinh Đoàn Xuân

---

> ✨ *Make your Linux terminal not just functional, but fascinating — and ready for serious development.*

