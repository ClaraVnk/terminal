# Bash / Zsh Configuration

![Bash Script](https://img.shields.io/badge/bash_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white) ![macOS](https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=macos&logoColor=F0F0F0) ![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

Made with love ❤️

This repository contains automated installation scripts for two use cases:

## 🍎 macOS - Full Development Environment
Complete setup for your main development machine with:
* **Homebrew** package manager
* **iTerm2** terminal with Dracula theme
* **Oh My Zsh** framework with Powerlevel10k visual prompt
* **Zsh plugins**: zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions
* **Modern CLI tools**: eza, fzf, direnv, atuin
* **GPG/YubiKey**: Full support with pinentry-mac and gpg-agent
* **Python dev tools**: devtools-claravnk (black, isort, flake8, bandit)
* **Optimized aliases** and shell configurations

## 🐧 Linux - Lightweight Tools for Remote Servers
Quick setup for remote Linux machines accessed via SSH from your macOS machine:
* **Modern CLI tools**: eza, atuin, fzf, direnv, neofetch
* **Simple prompt**: Colorful and efficient (no heavy frameworks)
* **Python dev tools**: devtools-claravnk (black, isort, flake8, bandit)
* **Essential aliases**: Optimized for productivity
* **Minimal footprint**: Fast shell startup (~50ms)
* **No GPG/YubiKey setup**: Operations forwarded from macOS client

---

## Installation

### For Linux (Bash - Lightweight)

```bash
git clone https://github.com/ClaraVnk/terminal.git && bash terminal/BASHRC_By_Loutre.sh
```

**Note**: After installation, restart your terminal or run `source ~/.bashrc` to apply changes.

### For macOS (Zsh - Full Setup)

```zsh
git clone https://github.com/ClaraVnk/terminal.git && zsh terminal/ZSHRC_By_Loutre.sh
```

**Important for macOS users:**
1. The script will install iTerm2 first
2. Open iTerm2 and run the script again to complete Oh My Zsh and Powerlevel10k setup
3. Restart your terminal or run `source ~/.zshrc` to apply changes
4. Run `p10k configure` to customize your Powerlevel10k prompt

---

## 🛠️ Tools Installed

### Common to Both Platforms
- **eza**: Modern replacement for `ls` with colors and icons
- **atuin**: Magical shell history with sync and search
- **fzf**: Fuzzy finder for command-line
- **direnv**: Environment switcher for shell
- **gnupg**: GNU Privacy Guard
- **devtools-claravnk**: Python development toolkit (black, isort, flake8, bandit)

### Linux Only
- **neofetch**: System information tool
- **jq**: JSON processor
- **bash-completion**: Programmable completion for Bash

### macOS Only
- **iTerm2**: Modern terminal emulator
- **Oh My Zsh**: Framework for managing Zsh configuration
- **Powerlevel10k**: Beautiful and fast Zsh theme
- **pinentry-mac**: GPG passphrase entry for macOS
- **YubiKey support**: Full GPG/SSH integration

---

## Customization (macOS only)

### Powerlevel10k
After installation, you can launch or relaunch the configuration with:

```zsh
p10k configure
```

### iTerm2 Dracula Theme
The script downloads the Dracula theme automatically. To apply it:
1. Open iTerm2 Preferences (⌘,)
2. Go to Profiles > Colors > Color Presets > Import...
3. Select the file: `~/.iterm2/themes/Dracula.itermcolors`
4. Apply the Dracula preset

---

## Backup & Restore (Migration between macOS machines)

These scripts are designed to help you migrate your complete macOS development environment to a new machine.

### Backup your environment 
Run the backup script to save your dotfiles, installed packages, SSH keys (optional), and Git config into a timestamped archive:
```bash
./backup.sh
```
This will create an archive in your home directory, e.g. `migration_backup_20230522_123456.tar.gz`.

### Restore your environment
To restore on a new macOS machine:
```bash
./restore.sh path_to/migration_backup_20230522_123456.tar.gz
```
The restore script will extract the archive, restore dotfiles, reinstall packages (Homebrew, pip, npm), optionally restore SSH keys, and Git config.

**Note:** These migration scripts are primarily intended for macOS-to-macOS migrations. For Linux machines, simply run the Bash installation script on each new machine.

---

## Contributions

Contributions are welcome!  
Feel free to open an issue or submit a pull request.  
Don't forget to give a star ⭐️ if you find this repository useful!

---

## License

MIT License © Loutre
