# ZSHRC By Loutre, inspired from PAPAMICA
# Environement : MACOS

# Détection de la langue du système
if [[ "$LANG" == fr_* ]]; then
  LANG_MSG_SCRIPT_RELAUNCH="🔄 Relance du script en utilisant Zsh..."
  LANG_MSG_INSTALLING="🔧 Installation de"
  LANG_MSG_INSTALLED="✅ installé avec succès."
  LANG_MSG_POWERLEVEL_CONFIG="⚠️ Voulez-vous lancer la configuration de Powerlevel10k maintenant ? (o/N)"
  LANG_MSG_POWERLEVEL_SKIP="⚠️ Configuration de Powerlevel10k non réalisée. Vous pouvez la relancer plus tard avec 'p10k configure'."
  LANG_MSG_PUBLISH_INSTALL="Souhaites-tu installer le script publish_py pour automatiser la publication de paquets Python ? (o/N)"
  LANG_MSG_PUBLISH_CANCEL="⚠️ Installation du script publish_py annulée."
  LANG_MSG_SETUP_COMPLETE="🎉 Configuration de l'environnement terminée."
else
  LANG_MSG_SCRIPT_RELAUNCH="🔄 Relaunching script using Zsh..."
  LANG_MSG_INSTALLING="🔧 Installing"
  LANG_MSG_INSTALLED="✅ successfully installed."
  LANG_MSG_POWERLEVEL_CONFIG="⚠️ Do you want to configure Powerlevel10k now? (y/N)"
  LANG_MSG_POWERLEVEL_SKIP="⚠️ Powerlevel10k configuration skipped. You can run it later with 'p10k configure'."
  LANG_MSG_PUBLISH_INSTALL="Do you want to install the publish_py script to automate Python package publishing? (y/N)"
  LANG_MSG_PUBLISH_CANCEL="⚠️ publish_py script installation cancelled."
  LANG_MSG_SETUP_COMPLETE="🎉 Environment setup completed."
fi

# Donne les droits d'exécution au script
chmod +x "$0"

# Ensure the script is running under Zsh
if [ -z "$ZSH_VERSION" ]; then
  echo "$LANG_MSG_SCRIPT_RELAUNCH"
  exec zsh "$0"
fi

install_if_missing() {
  if ! brew list "$1" &>/dev/null; then
    echo "$LANG_MSG_INSTALLING $1..."
    brew install "$1"
    echo "✅ $1 $LANG_MSG_INSTALLED"
  fi
}

backup_zshrc() {
  if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup_$(date +%Y%m%d_%H%M%S)
  fi
}

### INSTALLATION DE HOMEBREW SI ABSENT
if ! command -v brew &>/dev/null; then
  echo "$LANG_MSG_INSTALLING Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
  echo "✅ Homebrew $LANG_MSG_INSTALLED"
fi

### INSTALLATION DE iTerm2 SI ABSENT
if [ ! -d "/Applications/iTerm.app" ]; then
    echo "$LANG_MSG_INSTALLING iTerm2..."
    brew install --cask iterm2
    echo "✅ iTerm2 $LANG_MSG_INSTALLED"
fi

### TOUT LE RESTE NE S'EXECUTE QUE SI ON EST DANS ITERM2
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then

  ### INSTALLATION OH MY ZSH
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "$LANG_MSG_INSTALLING Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "✅ Oh My Zsh $LANG_MSG_INSTALLED"
  fi
  source $HOME/.oh-my-zsh/oh-my-zsh.sh

  ### INSTALLATION POWERLEVEL10K
  if ! brew list powerlevel10k &>/dev/null; then
    echo "$LANG_MSG_INSTALLING Powerlevel10k..."
    brew install powerlevel10k
    echo "✅ Powerlevel10k $LANG_MSG_INSTALLED"
  fi

  # Configuration de Powerlevel10k
  if ! grep -q "source $(brew --prefix)/opt/powerlevel10k/powerlevel10k.zsh-theme" ~/.zshrc; then
    backup_zshrc
    echo "source $(brew --prefix)/opt/powerlevel10k/powerlevel10k.zsh-theme" >> ~/.zshrc
  fi

  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi

  echo "$LANG_MSG_POWERLEVEL_CONFIG"
  read -r answer
  if [[ "$LANG" == fr_* && "$answer" =~ ^[oO]$ ]] || [[ "$LANG" != fr_* && "$answer" =~ ^[yY]$ ]]; then
    p10k configure
  else
    echo "$LANG_MSG_POWERLEVEL_SKIP"
  fi

  ### INSTALLATION ATUIN
  install_if_missing atuin
  if [[ $- == *i* ]]; then
    eval "$(atuin init zsh)"
  fi

  ### INSTALLATION DE PINENTRY-MAC & GNUPG
  for pkg in pinentry-mac gnupg; do
    install_if_missing "$pkg"
  done

  ### INSTALLATION DIRENV
  install_if_missing direnv

  ### CONFIGURATION DES OUTILS DANS ZSHRC
  backup_zshrc

  # Configuration d'Atuin
  if command -v atuin &>/dev/null; then
    if ! grep -q 'atuin init zsh' ~/.zshrc; then
      echo 'eval "$(atuin init zsh)"' >> ~/.zshrc
    fi
  fi

  # Configuration GPG/YubiKey
  if command -v gpgconf &>/dev/null; then
    if ! grep -q 'GPG_TTY=' ~/.zshrc; then
      {
        echo '# YubiKey + GPG config'
        echo 'export GPG_TTY="$(tty)"'
        echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)'
        echo 'gpgconf --launch gpg-agent'
      } >> ~/.zshrc
    fi
  fi

  # Configuration Direnv
  if command -v direnv &>/dev/null; then
    if ! grep -q 'eval "$(direnv hook zsh)"' ~/.zshrc; then
      echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
    fi
  fi

  ### INSTALLATION EZA
  install_if_missing eza

  # Ajout des alias eza dans ~/.zshrc
  if command -v eza &>/dev/null; then
    if ! grep -q 'alias ls=' ~/.zshrc; then
      {
        echo '# Alias eza'
        echo 'alias ls="eza -a --icons"'
        echo 'alias ll="eza -1a --icons"'
        echo 'alias ld="ll"'
        echo 'alias la="eza -lagh --icons"'
        echo 'alias lt="eza -a --tree --icons --level=2"'
        echo 'alias ltf="eza -a --tree --icons"'
        echo 'alias lat="eza -lagh --tree --icons"'
      } >> ~/.zshrc
    fi
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
    source ~/.zshrc
    echo "✅ publishpy $LANG_MSG_INSTALLED"
  else
    echo "$LANG_MSG_PUBLISH_CANCEL"
  fi

  echo "$LANG_MSG_SETUP_COMPLETE"
fi
fi