#!/usr/bin/env bash

# BASHRC By Loutre, inspired from PAPAMICA
# Environement : Linux

# Détection de la langue du système
if [[ "$LANG" == fr_* ]]; then
  LANG_MSG_SCRIPT_RELAUNCH="🔄 Relance du script en utilisant Bash..."
  LANG_MSG_INSTALLING="🔧 Installation de"
  LANG_MSG_INSTALLED="✅ installé avec succès."
  LANG_MSG_UPDATING="🔄 Mise à jour de"
  LANG_MSG_UPDATED="✅ mis à jour avec succès."
  LANG_MSG_ALREADY_INSTALLED="✅ version %s déjà installée (dernière version %s)."
  LANG_MSG_HOMEBREW_NOT_FOUND="🔧 Homebrew (Linuxbrew) non trouvé."
  LANG_MSG_APT_INSTALL="🔧 Installation des paquets manquants via apt..."
  LANG_MSG_APT_SUCCESS="✅ Paquets installés via apt."
  LANG_MSG_BREW_UPDATE="🔄 Mise à jour des paquets Homebrew..."
  LANG_MSG_PUBLISH_INSTALL="Souhaites-tu installer le script publish_py pour automatiser la publication de paquets Python ? (o/N)"
  LANG_MSG_PUBLISH_CANCEL="⚠️ Installation du script publish_py annulée."
  LANG_MSG_SETUP_COMPLETE="🎉 Configuration de l'environnement terminée."
  LANG_MSG_BASHIT_CONFIG="💡 Pour configurer Bash-it, tapez 'bash-it show aliases' et 'bash-it show plugins' après le redémarrage du terminal"
  LANG_MSG_BASHIT_ERROR="⚠️ Bash-it n'a pas été trouvé dans le chemin attendu."
else
  LANG_MSG_SCRIPT_RELAUNCH="🔄 Relaunching script using Bash..."
  LANG_MSG_INSTALLING="🔧 Installing"
  LANG_MSG_INSTALLED="✅ successfully installed."
  LANG_MSG_UPDATING="🔄 Updating"
  LANG_MSG_UPDATED="✅ successfully updated."
  LANG_MSG_ALREADY_INSTALLED="✅ version %s already installed (latest version %s)."
  LANG_MSG_HOMEBREW_NOT_FOUND="🔧 Homebrew (Linuxbrew) not found."
  LANG_MSG_APT_INSTALL="🔧 Installing missing packages via apt..."
  LANG_MSG_APT_SUCCESS="✅ Packages installed via apt."
  LANG_MSG_BREW_UPDATE="🔄 Updating Homebrew packages..."
  LANG_MSG_PUBLISH_INSTALL="Do you want to install the publish_py script to automate Python package publishing? (y/N)"
  LANG_MSG_PUBLISH_CANCEL="⚠️ publish_py script installation cancelled."
  LANG_MSG_SETUP_COMPLETE="🎉 Environment setup completed."
  LANG_MSG_BASHIT_CONFIG="💡 To configure Bash-it, type 'bash-it show aliases' and 'bash-it show plugins' after terminal restart"
  LANG_MSG_BASHIT_ERROR="⚠️ Bash-it was not found in the expected path."
fi

# Donne les droits d'exécution au script
chmod +x "$0"

# Ensure the script is running under Bash
if [ -z "$BASH_VERSION" ]; then
  echo "$LANG_MSG_SCRIPT_RELAUNCH"
  exec bash "$0"
fi

backup_bashrc() {
  if [ -f ~/.bashrc ]; then
    cp ~/.bashrc ~/.bashrc.backup_$(date +%Y%m%d_%H%M%S)
  fi
}

version_ge() {
  local ver1=$1 ver2=$2
  if [[ "$(printf '%s\n%s\n' "$ver2" "$ver1" | sort -V | head -n1)" == "$ver2" ]]; then
    return 0
  else
    return 1
  fi
}

### INSTALLATION DE HOMEBREW (Linuxbrew) SI ABSENT
if ! command -v brew &>/dev/null; then
  echo "$LANG_MSG_HOMEBREW_NOT_FOUND"
  if command -v apt &>/dev/null; then
    echo "$LANG_MSG_APT_INSTALL"
    sudo apt update
    sudo apt install -y eza atuin fzf direnv pinentry-tty gnupg jq
    echo "$LANG_MSG_APT_SUCCESS"
    exit 0
  else
    echo "$LANG_MSG_INSTALLING Homebrew (Linuxbrew)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Configuration du PATH pour Homebrew
    if [[ -d ~/.linuxbrew ]]; then
      eval "$(~/.linuxbrew/bin/brew shellenv)"
      echo 'eval "$(~/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
    elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
    fi
    
    echo "✅ Homebrew $LANG_MSG_INSTALLED"
  fi
fi

### INSTALLATION DE BASH-IT
if [ ! -d "$HOME/.bash_it" ]; then
  echo "$LANG_MSG_INSTALLING Bash-it..."
  git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
  ~/.bash_it/install.sh --silent
  echo "✅ Bash-it $LANG_MSG_INSTALLED"
fi

# Création/Sauvegarde du .bashrc
backup_bashrc

# Configuration de base Bash-it
{
  echo 'export BASH_IT="$HOME/.bash_it"'
  echo 'export BASH_IT_THEME="powerline-multiline"'
  echo 'source "$BASH_IT/bash_it.sh"'
} > ~/.bashrc

### MISE À JOUR DE BREW
echo "$LANG_MSG_BREW_UPDATE"
brew update

### INSTALLATION DE PAQUETS via Brew
install_or_upgrade_brew_package_latest() {
  local pkg=$1
  local min_version=$2
  echo "🔄 Vérification de $pkg..."
  if brew list --versions "$pkg" &>/dev/null; then
    local installed_version
    installed_version=$(brew list --versions "$pkg" | awk '{print $2}')
    local latest_version
    latest_version=$(brew info --json=v1 "$pkg" | jq -r '.[0].versions.stable')
    if version_ge "$installed_version" "$latest_version"; then
      printf "$LANG_MSG_ALREADY_INSTALLED\n" "$installed_version" "$latest_version"
      return
    else
      echo "$LANG_MSG_UPDATING $pkg ($installed_version → $latest_version)..."
      brew upgrade "$pkg"
      echo "✅ $pkg $LANG_MSG_UPDATED"
      return
    fi
  else
    echo "$LANG_MSG_INSTALLING $pkg..."
    brew install "$pkg"
    echo "✅ $pkg $LANG_MSG_INSTALLED"
  fi
}

# Installation des paquets avec leurs versions minimales
echo "🔄 Installation des outils..."
install_or_upgrade_brew_package_latest "eza" "0.10.0"
install_or_upgrade_brew_package_latest "atuin" "0.1.0"
install_or_upgrade_brew_package_latest "fzf" "0.38.0"
install_or_upgrade_brew_package_latest "direnv" "2.32.0"
install_or_upgrade_brew_package_latest "pinentry" "1.1.0"
install_or_upgrade_brew_package_latest "gnupg" "2.3.0"
echo "✅ Installation des outils terminée"

# Configuration dans ~/.bashrc
echo "🔄 Configuration des alias..."
if ! grep -q 'alias ls=' ~/.bashrc; then
  {
    echo '# Alias eza'
    echo 'alias ls="eza -a --icons"'
    echo 'alias ll="eza -1a --icons"'
    echo 'alias ld="ll"'
    echo 'alias la="eza -lagh --icons"'
    echo 'alias lt="eza -a --tree --icons --level=2"'
    echo 'alias ltf="eza -a --tree --icons"'
    echo 'alias lat="eza -lagh --tree --icons"'
  } >> ~/.bashrc
fi
echo "✅ Configuration des alias terminée"

# Configuration des outils
echo "🔄 Configuration des outils..."
{
  # Atuin
  echo 'eval "$(atuin init bash)"'
  
  # FZF
  echo '[ -f ~/.fzf.bash ] && source ~/.fzf.bash'
  
  # Direnv
  echo 'eval "$(direnv hook bash)"'
  
  # GPG/YubiKey
  echo '# YubiKey + GPG config'
  echo 'export GPG_TTY=$(tty)'
  if command -v gpgconf &>/dev/null; then
    echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)'
    echo 'gpgconf --launch gpg-agent'
  fi
} >> ~/.bashrc
echo "✅ Configuration des outils terminée"

### INSTALLATION DU SCRIPT D'ALIAS POUR PYTHON PACKAGE
echo "$LANG_MSG_PUBLISH_INSTALL"
read -r answer
if [[ "$LANG" == fr_* && "$answer" =~ ^[oO]$ ]] || [[ "$LANG" != fr_* && "$answer" =~ ^[yY]$ ]]; then
  echo "$LANG_MSG_INSTALLING publish_py..."
  tmpfile=$(mktemp)
  curl -L -o "$tmpfile" https://raw.githubusercontent.com/ClaraVnk/python-package/main/install_publish_alias.sh
  chmod +x "$tmpfile"
  "$tmpfile"
  rm -f "$tmpfile"
  source ~/.bashrc
  echo "✅ publishpy $LANG_MSG_INSTALLED"
else
  echo "$LANG_MSG_PUBLISH_CANCEL"
fi

echo "$LANG_MSG_SETUP_COMPLETE"
echo "$LANG_MSG_BASHIT_CONFIG"

# Rechargement de la configuration
exec bash