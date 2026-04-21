# 🧠 Fascinating Linux Setup Scripts

A collection of powerful setup scripts for Debian/Ubuntu systems — from **terminal customization** to **developer stack installation** — all in one place.  
Get your environment up and running beautifully in just a few commands.

---

## 🚀 Quick Start

### ⚡ Full Environment Setup

This script sets up your **Zsh terminal** (with Agnoster and plugins) as well as the **Developer Stack** (Docker, Node.js, uv, Apache2, PHP).

```bash
wget https://raw.githubusercontent.com/phuong0111/linux-setups/main/setup.sh
chmod +x setup.sh
./setup.sh
chsh -s $(which zsh)
zsh
```

> 💡 After installation, your terminal will open in **Zsh** with all developer tools ready for web, AI, or backend development.

---

## ✨ Features

### 🛠️ setup.sh (Unified Setup)

- 🎨 **Terminal setup**: Installs Oh My Zsh, Agnoster theme with Powerline fonts, and essential Zsh plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `fast-syntax-highlighting`, `zsh-autocomplete`). Safely updates `.zshrc` with a backup.
- 📦 **Base tools**: Updates apt repositories and installs `curl`, `git`, and build tools.
- 🐳 **Docker**: Installs Docker and `docker-compose`, configures `docker` group for current user.
- 🟢 **Node.js**: Installs Node 24 and npm 11 using `nvm`.
- 🐍 **Python manager**: Installs `uv` from Astral.
- 🧱 **Web Server**: Installs Apache2 and PHP (`libapache2-mod-php`).
- 🌐 Optionally enables **UFW** firewall rules for Apache (requires manual explicit enable).
- 🧩 Automatically sources environment files for `nvm` and `uv`.

---

## 📋 Requirements

| Requirement        | Description                                 |
| ------------------ | ------------------------------------------- |
| 🖥️ **OS**          | Debian / Ubuntu (requires `apt`)            |
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

> ✨ _Make your Linux terminal not just functional, but fascinating — and ready for serious development._
