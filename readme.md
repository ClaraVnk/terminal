# Bash / Zsh Configuration

![Bash Script](https://img.shields.io/badge/bash_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white) ![macOS](https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=macos&logoColor=F0F0F0) ![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

Made with love ❤️

This repository contains a complete automated installation script to set up a modern and powerful Zsh environment on macOS or Bash on Linux, including:
* Homebrew package manager
* iTerm2 terminal (Dracula theme recommended) (macOs)
* Oh My Zsh framework (macOs)
* Powerlevel10k visual prompt (macOs)
* Essential Zsh plugins: zsh-autocomplete, zsh-autosuggestions, zsh-syntax-highlighting (macOs)
* Modern command line tools: exa/eza, fzf, direnv, atuin
* SSH/GPG security with YubiKey support
* Handy aliases and optimized configurations

---

## Installation

# Bash

```bash
git clone https://github.com/ClaraVnk/terminal.git && bash terminal/BASHRC_By_Loutre.sh && source ~/.bashrc
```

# Zsh

```zsh
git clone https://github.com/ClaraVnk/terminal.git && zsh terminal/ZSHRC_By_Loutre.sh && source ~/.zshrc
```

---

## Customization (macOs only)

### Powerlevel10k:
After installation, you can launch or relaunch the configuration with:

```zsh
p10k configure
```

### iTerm2 Dracula Theme:
The script cannot automatically import the theme. You need to:
1. Download the `.itermcolors` file here: https://draculatheme.com/iterm
2. In iTerm2, go to Preferences > Profiles > Colors > Color Presets > Import... and select the downloaded file.
3. Apply the Dracula preset from this menu.

---

## Backup & Restore (migration)

### Backup your environnement 
Run the backup script to save your dotfiles, installed packages, SSH keys (optional), and Git config into a timestamped archive:
```bash
./backup.sh
```
This will create an archive in your home directory, e.g. migration_backup_20230522_123456.tar.gz.

### Restore your environment
To restore on a new machine:
```bash
./restore.sh path_to/migration_backup_20230522_123456.tar.gz
```
The restore script will extract the archive, restore dotfiles, reinstall packages (Homebrew, pip, npm), optionally restore SSH keys, and Git config.

---

## Contributions

Contributions are welcome!  
Feel free to open an issue or submit a pull request.  
Don't forget to give a star ⭐️ if you find this repository useful!

---

## License

MIT License © Loutre
