#!/usr/bin/env bash

# BASHRC By Loutre, inspired from PAPAMICA
# Environment: Linux

# Language detection
if [[ "$LANG" == fr_* ]]; then
  LANG_MSG_SCRIPT_RELAUNCH="🔄 Relance du script en utilisant Bash..."
  LANG_MSG_INSTALLING="🔧 Installation de"
  LANG_MSG_INSTALLED="✅ installé avec succès."
  LANG_MSG_ALREADY_INSTALLED="déjà installé"
  LANG_MSG_INSTALL_ERROR="❌ Échec de l'installation de"
  LANG_MSG_HOMEBREW_NOT_FOUND="🔧 Homebrew (Linuxbrew) non trouvé."
  LANG_MSG_APT_INSTALL="🔧 Installation des paquets manquants via apt..."
  LANG_MSG_APT_SUCCESS="✅ Paquets installés via apt."
  LANG_MSG_BREW_UPDATE="🔄 Mise à jour des paquets Homebrew..."
  LANG_MSG_SETUP_COMPLETE="🎉 Configuration de l'environnement terminée."
else
  LANG_MSG_SCRIPT_RELAUNCH="🔄 Relaunching script using Bash..."
  LANG_MSG_INSTALLING="🔧 Installing"
  LANG_MSG_INSTALLED="✅ successfully installed."
  LANG_MSG_ALREADY_INSTALLED="already installed"
  LANG_MSG_INSTALL_ERROR="❌ Failed to install"
  LANG_MSG_HOMEBREW_NOT_FOUND="🔧 Homebrew (Linuxbrew) not found."
  LANG_MSG_APT_INSTALL="🔧 Installing missing packages via apt..."
  LANG_MSG_APT_SUCCESS="✅ Packages installed via apt."
  LANG_MSG_BREW_UPDATE="🔄 Updating Homebrew packages..."
  LANG_MSG_SETUP_COMPLETE="🎉 Environment setup completed."
fi

# Re-exec under Bash if needed
if [ -z "$BASH_VERSION" ]; then
  echo "$LANG_MSG_SCRIPT_RELAUNCH"
  exec bash "$0" "$@"
fi

install_if_missing() {
  local package=$1
  if command -v "$package" &>/dev/null; then
    echo "✅ $package $LANG_MSG_ALREADY_INSTALLED"
    return 0
  fi
  echo "$LANG_MSG_INSTALLING $package..."
  if brew install "$package"; then
    echo "✅ $package $LANG_MSG_INSTALLED"
  else
    echo "$LANG_MSG_INSTALL_ERROR $package"
    return 1
  fi
}

backup_bashrc() {
  if [ -f "$HOME/.bashrc" ]; then
    cp "$HOME/.bashrc" "$HOME/.bashrc.backup_$(date +%Y%m%d_%H%M%S)"
  fi
}

### PACKAGE MANAGER DETECTION
USE_APT=false
if ! command -v brew &>/dev/null; then
  if command -v apt &>/dev/null; then
    echo "$LANG_MSG_APT_INSTALL"
    sudo apt update
    sudo apt install -y eza atuin fzf direnv gnupg jq bash-completion neofetch
    echo "$LANG_MSG_APT_SUCCESS"
    USE_APT=true
  else
    echo "$LANG_MSG_HOMEBREW_NOT_FOUND"
    echo "$LANG_MSG_INSTALLING Homebrew (Linuxbrew)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -d "$HOME/.linuxbrew" ]]; then
      eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
    elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    echo "✅ Homebrew $LANG_MSG_INSTALLED"
  fi
fi

backup_bashrc

# Lightweight configuration for remote servers
{
  echo '# Homebrew PATH'
  if [[ -d "$HOME/.linuxbrew" ]]; then
    echo 'eval "$(~/.linuxbrew/bin/brew shellenv)"'
  elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
  fi

  echo 'export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "'

  echo '# Enable bash completion'
  echo 'if [ -f /etc/bash_completion ]; then'
  echo '  . /etc/bash_completion'
  echo 'elif [ -f /usr/share/bash-completion/bash_completion ]; then'
  echo '  . /usr/share/bash-completion/bash_completion'
  echo 'fi'
  echo ''

  echo '# Tool configurations'
  echo 'command -v atuin >/dev/null 2>&1 && eval "$(atuin init bash)"'
  echo 'command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"'

  echo 'if command -v eza >/dev/null 2>&1; then'
  echo '  alias ls="eza -a --icons"'
  echo '  alias ll="eza -1a --icons"'
  echo '  alias ld="ll"'
  echo '  alias la="eza -lagh --icons"'
  echo '  alias lt="eza -a --tree --icons --level=2"'
  echo '  alias ltf="eza -a --tree --icons"'
  echo '  alias lat="eza -lagh --tree --icons"'
  echo 'fi'

  echo '[ -f ~/.fzf.bash ] && source ~/.fzf.bash'

  echo 'export HISTSIZE=10000'
  echo 'export HISTFILESIZE=20000'
  echo 'export HISTCONTROL=ignoredups:erasedups'
  echo 'shopt -s histappend'
} > "$HOME/.bashrc"

### TOOL INSTALLATION (if not already done via apt)
if [ "$USE_APT" = false ]; then
  echo "🔄 Installation des outils via Homebrew..."
  for pkg in eza atuin fzf direnv gnupg neofetch; do
    install_if_missing "$pkg"
  done
else
  echo "✅ Outils déjà installés via apt"
fi

### PYTHON DEV TOOLKIT
if ! pip3 show devtools-claravnk &>/dev/null 2>&1; then
  echo "🔧 Installation de python-dev-toolkit..."
  if pip3 install --break-system-packages devtools-claravnk[dev]; then
    echo "✅ python-dev-toolkit installé avec succès (black, isort, flake8, bandit)"
  else
    echo "⚠️ Échec de l'installation de python-dev-toolkit"
  fi
else
  echo "✅ python-dev-toolkit $LANG_MSG_ALREADY_INSTALLED"
fi

echo "$LANG_MSG_SETUP_COMPLETE"

if [[ "$LANG" == fr_* ]]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🎯 PROCHAINES ÉTAPES - Configuration de votre espace de travail"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "1️⃣  Recharger votre configuration :"
  echo "    source ~/.bashrc"
  echo ""
  echo "2️⃣  Configurer Atuin (historique synchronisé) :"
  echo "    atuin register -u <votre-email> -p <mot-de-passe>"
  echo "    atuin login -u <votre-email> -p <mot-de-passe>"
  echo "    atuin sync"
  echo ""
  echo "3️⃣  Tester les outils installés :"
  echo "    neofetch              # Afficher les infos système"
  echo "    eza -la               # Lister les fichiers avec style"
  echo "    fzf                   # Recherche floue interactive"
  echo ""
  echo "4️⃣  Outils Python disponibles :"
  echo "    black <fichier.py>    # Formater le code"
  echo "    isort <fichier.py>    # Trier les imports"
  echo "    flake8 <fichier.py>   # Linter"
  echo "    bandit <fichier.py>   # Analyse de sécurité"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🎯 NEXT STEPS - Configure your workspace"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "1️⃣  Reload your configuration:"
  echo "    source ~/.bashrc"
  echo ""
  echo "2️⃣  Configure Atuin (synced history):"
  echo "    atuin register -u <your-email> -p <password>"
  echo "    atuin login -u <your-email> -p <password>"
  echo "    atuin sync"
  echo ""
  echo "3️⃣  Test installed tools:"
  echo "    neofetch              # Display system info"
  echo "    eza -la               # List files with style"
  echo "    fzf                   # Interactive fuzzy finder"
  echo ""
  echo "4️⃣  Python tools available:"
  echo "    black <file.py>       # Format code"
  echo "    isort <file.py>       # Sort imports"
  echo "    flake8 <file.py>      # Linter"
  echo "    bandit <file.py>      # Security analysis"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi
