#!/usr/bin/env bash
set -e

check_internet() {
  curl -s --head http://www.google.com/ | head -n 1 | grep "HTTP/[12][.][01] [23].." >/dev/null
}

version_ge() {
  # Returns true if $1 >= $2
  [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

install_or_upgrade_brew_package_latest() {
  local package=$1
  local installed_version=""
  local latest_version=""
  if brew list --versions "$package" &>/dev/null; then
    installed_version=$(brew list --versions "$package" | awk '{print $2}')
  fi
  latest_version=$(brew info --json=v1 "$package" | jq -r '.[0].versions.stable')
  if [ -z "$latest_version" ]; then
    echo "⚠️ Could not determine latest version for $package. Installing/upgrading normally."
    brew upgrade "$package" || brew install "$package"
    return
  fi
  if [ -z "$installed_version" ]; then
    echo "🔧 Installing $package (latest version: $latest_version)..."
    brew install "$package"
    echo "✅ $package installed successfully."
  elif version_ge "$installed_version" "$latest_version"; then
    echo "✅ $package is already at the latest version ($installed_version)."
  else
    echo "🔄 Upgrading $package from $installed_version to $latest_version..."
    brew upgrade "$package"
    echo "✅ $package upgraded successfully."
  fi
}

### INSTALL HOMEBREW (Linuxbrew) IF MISSING, OR FALL BACK TO APT
if ! command -v brew &>/dev/null; then
  echo "🔧 Homebrew (Linuxbrew) not found."
  if command -v apt &>/dev/null; then
    echo "🔧 Installing missing packages via apt..."
    sudo apt update
    sudo apt install -y eza atuin fzf direnv pinentry-tty gnupg jq curl
    echo "✅ Packages installed via apt."
    exit 0
  else
    echo "🔧 Installing Homebrew (Linuxbrew)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Reload PATH for the current session
    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    echo "✅ Homebrew installed successfully."
  fi
fi

### Ensure jq is installed for JSON parsing
if ! command -v jq &>/dev/null; then
  echo "🔧 Installing jq..."
  brew install jq
  echo "✅ jq installed successfully."
fi

### UPDATE BREW
echo "🔄 Updating Homebrew packages..."
brew update

### INSTALL OR UPGRADE PACKAGES via Brew
for pkg in eza atuin fzf direnv pinentry gnupg; do
  install_or_upgrade_brew_package_latest "$pkg"
done

### Add eza aliases to ~/.bashrc only if missing
if ! grep -q 'alias ls=' ~/.bashrc; then
  echo '# eza aliases' >> ~/.bashrc
  echo 'alias ls="eza -a --icons"' >> ~/.bashrc
  echo 'alias ll="eza -1a --icons"' >> ~/.bashrc
  echo 'alias ld="ll"' >> ~/.bashrc
  echo 'alias la="eza -lagh --icons"' >> ~/.bashrc
  echo 'alias lt="eza -a --tree --icons --level=2"' >> ~/.bashrc
  echo 'alias ltf="eza -a --tree --icons"' >> ~/.bashrc
  echo 'alias lat="eza -lagh --tree --icons"' >> ~/.bashrc
  echo "✅ eza aliases added to ~/.bashrc"
fi

### Initialize atuin in bashrc
if ! grep -q 'atuin init bash' ~/.bashrc; then
  echo 'eval "$(atuin init bash)"' >> ~/.bashrc
  echo "✅ AtuIn initialization added to ~/.bashrc"
fi

### Initialize fzf in bashrc
if ! grep -q 'source ~/.fzf.bash' ~/.bashrc; then
  echo '[ -f ~/.fzf.bash ] && source ~/.fzf.bash' >> ~/.bashrc
  echo "✅ fzf initialization added to ~/.bashrc"
fi

### Initialize direnv in bashrc
if ! grep -q 'eval "$(direnv hook bash)"' ~/.bashrc; then
  echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
  echo "✅ direnv initialization added to ~/.bashrc"
fi

### GPG / pinentry configuration for YubiKey
if ! grep -q 'GPG_TTY=' ~/.bashrc; then
  echo '# YubiKey + GPG config' >> ~/.bashrc
  echo 'export GPG_TTY=$(tty)' >> ~/.bashrc
  echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)' >> ~/.bashrc
  echo 'gpgconf --launch gpg-agent' >> ~/.bashrc
  echo "✅ GPG/YubiKey configuration added to ~/.bashrc"
fi

### INSTALL THE ALIAS SCRIPT FOR PYTHON PACKAGE
echo "Would you like to install the publish_py script to automate Python package publishing? (y/N)"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "🔧 Installing the publish_py script..."
  tmpfile=$(mktemp)
  curl -L -o "$tmpfile" https://raw.githubusercontent.com/ClaraVnk/python-package/main/install_publish_alias.sh
  chmod +x "$tmpfile"
  "$tmpfile"
  rm -f "$tmpfile"
  source ~/.bashrc
  echo "✅ Alias publishpy added to ~/.bashrc"
else
  echo "⚠️ publish_py script installation cancelled."
fi

echo "🎉 Setup complete !"