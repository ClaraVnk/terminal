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
  LANG_MSG_AI_ASSISTANT_PROMPT="Souhaitez-vous installer bash-ai, un assistant AI pour votre terminal ? Il offre une interface en langage naturel et un système de plugins (o/N)"
  LANG_MSG_AI_ASSISTANT_INSTALLING="🔧 Installation de bash-ai..."
  LANG_MSG_AI_ASSISTANT_CANCEL="⚠️ Installation de bash-ai annulée"
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
  LANG_MSG_AI_ASSISTANT_PROMPT="Would you like to install bash-ai, an AI assistant for your terminal? It offers a natural language interface and plugin system (y/N)"
  LANG_MSG_AI_ASSISTANT_INSTALLING="🔧 Installing bash-ai..."
  LANG_MSG_AI_ASSISTANT_CANCEL="⚠️ bash-ai installation cancelled"
fi

# Donne les droits d'exécution au script
chmod +x "$0"

# Ensure the script is running under Bash
if [ -z "$BASH_VERSION" ]; then
  echo "$LANG_MSG_SCRIPT_RELAUNCH"
  exec bash "$0"
fi

install_if_missing() {
  local package=$1
  if ! command -v "$package" &>/dev/null && ! brew list "$package" &>/dev/null; then
    echo "$LANG_MSG_INSTALLING $package..."
    brew install "$package"
    if [ $? -eq 0 ]; then
      echo "✅ $package $LANG_MSG_INSTALLED"
    else
      echo "❌ Erreur lors de l'installation de $package"
      return 1
    fi
  else
    echo "✅ $package est déjà installé"
  fi
}

backup_bashrc() {
  if [ -f ~/.bashrc ]; then
    cp ~/.bashrc ~/.bashrc.backup_$(date +%Y%m%d_%H%M%S)
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

# Configuration de base Bash-it et outils
{
  # Configuration de base
  echo 'export BASH_IT="$HOME/.bash_it"'
  echo 'export BASH_IT_THEME="powerline-multiline"'
  
  # Homebrew PATH (doit être avant tout le reste)
  echo '# Homebrew PATH configuration'
  if [[ -d ~/.linuxbrew ]]; then
    echo 'eval "$(~/.linuxbrew/bin/brew shellenv)"'
  elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
  fi
  
  # Source Bash-it
  echo 'source "$BASH_IT/bash_it.sh"'
  
  # Configurations des outils avec vérification de leur existence
  echo '# Tool configurations'
  echo 'command -v atuin >/dev/null 2>&1 && eval "$(atuin init bash)"'
  
  echo 'command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"'
  
  echo 'if command -v gpgconf >/dev/null 2>&1; then'
  echo '  export GPG_TTY="$(tty)"'
  echo '  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"'
  echo '  gpgconf --launch gpg-agent 2>/dev/null'
  echo 'fi'
  
  # Alias eza avec vérification
  echo 'if command -v eza >/dev/null 2>&1; then'
  echo '  alias ls="eza -a --icons"'
  echo '  alias ll="eza -1a --icons"'
  echo '  alias ld="ll"'
  echo '  alias la="eza -lagh --icons"'
  echo '  alias lt="eza -a --tree --icons --level=2"'
  echo '  alias ltf="eza -a --tree --icons"'
  echo '  alias lat="eza -lagh --tree --icons"'
  echo 'fi'
  
  # FZF
  echo '[ -f ~/.fzf.bash ] && source ~/.fzf.bash'
} > ~/.bashrc

### INSTALLATION DES OUTILS
echo "🔄 Installation des outils..."
install_if_missing "eza"
install_if_missing "atuin"
install_if_missing "fzf"
install_if_missing "direnv"
install_if_missing "pinentry"
install_if_missing "gnupg"

### INSTALLATION DE BASH-AI
echo "$LANG_MSG_AI_ASSISTANT_PROMPT"
read -r answer
if [[ "$LANG" == fr_* && "$answer" =~ ^[oO]$ ]] || [[ "$LANG" != fr_* && "$answer" =~ ^[yY]$ ]]; then
    echo "$LANG_MSG_AI_ASSISTANT_INSTALLING"
    curl -sS https://raw.githubusercontent.com/hezkore/bash-ai/main/install.sh | bash
else
    echo "$LANG_MSG_AI_ASSISTANT_CANCEL"
fi

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

# Ajout des messages pour le rechargement
if [[ "$LANG" == fr_* ]]; then
  echo "💡 Pour appliquer les changements, vous pouvez :"
  echo "   - Soit ouvrir un nouveau terminal"
  echo "   - Soit taper 'source ~/.bashrc' dans le terminal actuel"
else
  echo "💡 To apply changes, you can either:"
  echo "   - Open a new terminal"
  echo "   - Type 'source ~/.bashrc' in the current terminal"
fi