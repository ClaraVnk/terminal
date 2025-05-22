#!/usr/bin/env bash

set -e

check_internet() {
  if ! curl -s --head https://www.google.com | head -n 1 | grep "HTTP/[12][.][01] [23].." >/dev/null; then
    echo "❌ Pas de connexion Internet détectée. Veuillez vérifier votre connexion et réessayer."
    exit 1
  fi
}

version_ge() {
  # Compare deux versions $1 and $2
  # Returns 0 if $1 >= $2, 1 otherwise
  # Usage: version_ge "1.2.3" "1.2.0"
  local ver1=$1 ver2=$2
  # Use sort -V to compare versions
  if [[ "$(printf '%s\n%s\n' "$ver2" "$ver1" | sort -V | head -n1)" == "$ver2" ]]; then
    return 0
  else
    return 1
  fi
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

check_internet

### INSTALLATION DE HOMEBREW (Linuxbrew) SI ABSENT
if ! command -v brew &>/dev/null; then
  echo "🔧 Homebrew (Linuxbrew) non trouvé."
  if command -v apt &>/dev/null; then
    echo "🔧 Installation des paquets manquants via apt..."
    sudo apt update
    sudo apt install -y eza atuin fzf direnv pinentry-tty gnupg jq
    echo "✅ Paquets installés via apt."
    # Le reste du script suppose la présence de brew, donc on sort ici.
    exit 0
  else
    echo "🔧 Installation de Homebrew (Linuxbrew)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Recharge le PATH pour la session en cours
    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    echo "✅ Homebrew installé avec succès."
  fi
fi

# Recharge le PATH pour la session en cours (après installation de Homebrew)
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

### INSTALLATION DE jq SI ABSENT (nécessaire pour la fonction d'installation)
if ! command -v jq &>/dev/null; then
  echo "🔧 Installation de jq..."
  brew install jq
  echo "✅ jq installé avec succès."
fi

### MISE À JOUR DE BREW
echo "🔄 Mise à jour des paquets Homebrew..."
brew update

### INSTALLATION DE PAQUETS via Brew

install_or_upgrade_brew_package_latest() {
  local pkg=$1
  if brew list --versions "$pkg" &>/dev/null; then
    local installed_version
    installed_version=$(brew list --versions "$pkg" | awk '{print $2}')
    local latest_version
    latest_version=$(brew info --json=v1 "$pkg" | jq -r '.[0].versions.stable')
    if version_ge "$installed_version" "$latest_version"; then
      echo "✅ $pkg version $installed_version déjà installée (dernière version $latest_version)."
      return
    else
      echo "🔄 Mise à jour de $pkg de la version $installed_version à la version $latest_version..."
      brew upgrade "$pkg"
      echo "✅ $pkg mis à jour avec succès."
      return
    fi
  else
    echo "🔧 Installation de $pkg..."
    brew install "$pkg"
    echo "✅ $pkg installé avec succès."
  fi
}

# Exa → eza minimum version 0.10.0 (example)
install_or_upgrade_brew_package_latest "eza" "0.10.0"

# AtuIn (pas de version minimale connue, on installe s'il manque)
if ! command -v atuin &>/dev/null; then
  echo "🔧 Installation de AtuIn..."
  brew install atuin
  echo "✅ AtuIn installé avec succès."
fi

# fzf minimum version 0.38.0 (example)
install_or_upgrade_brew_package_latest "fzf" "0.38.0"

# Prioriser apt pour direnv si possible
if command -v apt &>/dev/null; then
  if ! command -v direnv &>/dev/null; then
    echo "🔧 Installation de direnv via apt..."
    sudo apt install -y direnv
    echo "✅ direnv installé avec apt."
  fi
else
  install_or_upgrade_brew_package_latest "direnv" "2.32.0"
fi

# pinentry (Linux version) minimum version 1.1.0 (example)
install_or_upgrade_brew_package_latest "pinentry" "1.1.0"

# gnupg minimum version 2.3.0 (example)
install_or_upgrade_brew_package_latest "gnupg" "2.3.0"

# Ajout des alias eza dans ~/.bashrc uniquement s'ils sont absents
if ! grep -q 'alias ls=' ~/.bashrc; then
  echo '# Alias eza' >> ~/.bashrc
  echo 'alias ls="eza -a --icons"' >> ~/.bashrc
  echo 'alias ll="eza -1a --icons"' >> ~/.bashrc
  echo 'alias ld="ll"' >> ~/.bashrc
  echo 'alias la="eza -lagh --icons"' >> ~/.bashrc
  echo 'alias lt="eza -a --tree --icons --level=2"' >> ~/.bashrc
  echo 'alias ltf="eza -a --tree --icons"' >> ~/.bashrc
  echo 'alias lat="eza -lagh --tree --icons"' >> ~/.bashrc
  echo "✅ Alias eza ajoutés à ~/.bashrc"
fi

# Initialisation atuin dans bashrc
if ! grep -q 'atuin init bash' ~/.bashrc; then
  echo 'eval "$(atuin init bash)"' >> ~/.bashrc
  echo "✅ Initialisation AtuIn ajoutée à ~/.bashrc"
fi

# Initialisation fzf dans bashrc
if ! grep -q 'source ~/.fzf.bash' ~/.bashrc; then
  echo '[ -f ~/.fzf.bash ] && source ~/.fzf.bash' >> ~/.bashrc
  echo "✅ Initialisation fzf ajoutée à ~/.bashrc"
fi

# Initialisation direnv dans bashrc
if ! grep -q 'eval "$(direnv hook bash)"' ~/.bashrc; then
  echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
  echo "✅ Initialisation direnv ajoutée à ~/.bashrc"
fi

# Configuration GPG / pinentry pour YubiKey
if ! grep -q 'GPG_TTY=' ~/.bashrc; then
  echo '# YubiKey + GPG config' >> ~/.bashrc
  echo 'export GPG_TTY=$(tty)' >> ~/.bashrc
  echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)' >> ~/.bashrc
  echo 'gpgconf --launch gpg-agent' >> ~/.bashrc
  echo "✅ Configuration GPG/YubiKey ajoutée à ~/.bashrc"
fi

### INSTALLATION DU SCRIPT D'ALIAS POUR PYTHON PACKAGE
echo "Souhaites-tu installer le script publish_py pour automatiser la publication de paquets Python ? (y/N)"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "🔧 Installation du script publish_py..."
  curl -L -o ~/install_publish_alias.sh https://raw.githubusercontent.com/ClaraVnk/python-package/main/install_publish_alias.sh
  chmod +x ~/install_publish_alias.sh
  ~/install_publish_alias.sh
  rm -f ~/install_publish_alias.sh
  source ~/.bashrc
  echo "✅ Alias publishpy ajouté à ~/.bashrc"
else
  echo "⚠️ Installation du script publish_py annulée."
fi

echo "🎉 Configuration terminée !"