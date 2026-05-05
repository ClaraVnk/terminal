#!/usr/bin/env zsh

# ZSHRC By Loutre, inspired from PAPAMICA
# Environment: macOS

# Language detection
if [[ "$LANG" == fr_* ]]; then
  LANG_MSG_SCRIPT_RELAUNCH="🔄 Relance du script en utilisant Zsh..."
  LANG_MSG_INSTALLING="🔧 Installation de"
  LANG_MSG_INSTALLED="✅ installé avec succès."
  LANG_MSG_ALREADY_INSTALLED="déjà installé"
  LANG_MSG_INSTALL_ERROR="❌ Échec de l'installation de"
  LANG_MSG_POWERLEVEL_CONFIG="💡 Pour configurer Powerlevel10k, tapez 'p10k configure' après le redémarrage du terminal"
  LANG_MSG_POWERLEVEL_ERROR="⚠️ Le thème Powerlevel10k n'a pas été trouvé dans le chemin attendu."
  LANG_MSG_PUBLISH_INSTALL="Souhaites-tu installer le script publish_py pour automatiser la publication de paquets Python ? (o/N)"
  LANG_MSG_PUBLISH_CANCEL="⚠️ Installation du script publish_py annulée."
  LANG_MSG_SETUP_COMPLETE="🎉 Configuration de l'environnement terminée."
  LANG_MSG_ITERM_AI="💡 Pour activer l'IA dans iTerm2 :"
  LANG_MSG_ITERM_AI_STEPS="   1. Ouvrez les préférences d'iTerm2 (⌘,)\n   2. Allez dans 'General' > 'Magic'\n   3. Activez 'Enable AI features'\n   4. Configurez votre clé API OpenAI"
  LANG_MSG_ITERM_AI_INSTALL="🔧 Installation du plugin AI pour iTerm2..."
  LANG_MSG_ITERM_AI_SUCCESS="✅ Plugin AI iTerm2 installé avec succès"
  LANG_MSG_ITERM_AI_PROMPT="Souhaitez-vous installer le plugin AI pour iTerm2 ? Il permet d'utiliser l'IA générative directement dans votre terminal (o/N)"
  LANG_MSG_ITERM_AI_CANCEL="⚠️ Installation du plugin AI iTerm2 annulée"
  LANG_MSG_ITERM_THEME="🎨 Téléchargement du thème Dracula pour iTerm2..."
  LANG_MSG_ITERM_THEME_SUCCESS="✅ Thème Dracula téléchargé avec succès"
  LANG_MSG_ITERM_THEME_STEPS="💡 Pour activer le thème Dracula dans iTerm2 :\n   1. Ouvrez les préférences d'iTerm2 (⌘,)\n   2. Allez dans 'Profiles' > 'Colors'\n   3. Cliquez sur 'Color Presets...' > 'Import...'\n   4. Sélectionnez le fichier : ~/.iterm2/themes/Dracula.itermcolors\n   5. Sélectionnez 'Dracula' dans 'Color Presets...'"
else
  LANG_MSG_SCRIPT_RELAUNCH="🔄 Relaunching script using Zsh..."
  LANG_MSG_INSTALLING="🔧 Installing"
  LANG_MSG_INSTALLED="✅ successfully installed."
  LANG_MSG_ALREADY_INSTALLED="already installed"
  LANG_MSG_INSTALL_ERROR="❌ Failed to install"
  LANG_MSG_POWERLEVEL_CONFIG="💡 To configure Powerlevel10k, type 'p10k configure' after terminal restart"
  LANG_MSG_POWERLEVEL_ERROR="⚠️ Powerlevel10k theme was not found in the expected path."
  LANG_MSG_PUBLISH_INSTALL="Do you want to install the publish_py script to automate Python package publishing? (y/N)"
  LANG_MSG_PUBLISH_CANCEL="⚠️ publish_py script installation cancelled."
  LANG_MSG_SETUP_COMPLETE="🎉 Environment setup completed."
  LANG_MSG_ITERM_AI="💡 To enable AI in iTerm2:"
  LANG_MSG_ITERM_AI_STEPS="   1. Open iTerm2 preferences (⌘,)\n   2. Go to 'General' > 'Magic'\n   3. Enable 'Enable AI features'\n   4. Configure your OpenAI API key"
  LANG_MSG_ITERM_AI_INSTALL="🔧 Installing iTerm2 AI plugin..."
  LANG_MSG_ITERM_AI_SUCCESS="✅ iTerm2 AI plugin successfully installed"
  LANG_MSG_ITERM_AI_PROMPT="Would you like to install the iTerm2 AI plugin? It enables generative AI features directly in your terminal (y/N)"
  LANG_MSG_ITERM_AI_CANCEL="⚠️ iTerm2 AI plugin installation cancelled"
  LANG_MSG_ITERM_THEME="🎨 Downloading Dracula theme for iTerm2..."
  LANG_MSG_ITERM_THEME_SUCCESS="✅ Dracula theme successfully downloaded"
  LANG_MSG_ITERM_THEME_STEPS="💡 To activate Dracula theme in iTerm2:\n   1. Open iTerm2 preferences (⌘,)\n   2. Go to 'Profiles' > 'Colors'\n   3. Click on 'Color Presets...' > 'Import...'\n   4. Select the file: ~/.iterm2/themes/Dracula.itermcolors\n   5. Select 'Dracula' from 'Color Presets...'"
fi

# Re-exec under Zsh if needed
if [ -z "$ZSH_VERSION" ]; then
  echo "$LANG_MSG_SCRIPT_RELAUNCH"
  exec zsh "$0" "$@"
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

backup_zshrc() {
  if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup_$(date +%Y%m%d_%H%M%S)"
  fi
}

confirm() {
  local answer
  read -r "answer?$1 "
  if [[ "$LANG" == fr_* ]]; then
    [[ "$answer" =~ ^[oO]$ ]]
  else
    [[ "$answer" =~ ^[yY]$ ]]
  fi
}

### HOMEBREW
if ! command -v brew &>/dev/null; then
  echo "$LANG_MSG_INSTALLING Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  echo "✅ Homebrew $LANG_MSG_INSTALLED"
fi

### iTerm2
if [ ! -d "/Applications/iTerm.app" ]; then
  echo "$LANG_MSG_INSTALLING iTerm2..."
  brew install --cask iterm2
  echo "✅ iTerm2 $LANG_MSG_INSTALLED"

  echo "$LANG_MSG_ITERM_THEME"
  mkdir -p "$HOME/.iterm2/themes"
  if curl -fsSL "https://raw.githubusercontent.com/dracula/iterm/master/Dracula.itermcolors" \
       -o "$HOME/.iterm2/themes/Dracula.itermcolors"; then
    echo "$LANG_MSG_ITERM_THEME_SUCCESS"
    printf '%b\n' "$LANG_MSG_ITERM_THEME_STEPS"
  else
    echo "⚠️ Échec du téléchargement du thème Dracula"
  fi
fi

### iTerm2 AI Plugin
if [ ! -d "/Applications/iTerm2 AI Plugin.app" ]; then
  if confirm "$LANG_MSG_ITERM_AI_PROMPT"; then
    echo "$LANG_MSG_ITERM_AI_INSTALL"
    tmp_dir=$(mktemp -d)
    trap 'rm -rf "$tmp_dir"' EXIT
    if curl -fsSL "https://iterm2.com/downloads/ai/iTerm2%20AI%20Plugin.zip" \
         -o "$tmp_dir/iterm2_ai_plugin.zip" \
       && unzip -q "$tmp_dir/iterm2_ai_plugin.zip" -d "/Applications/"; then
      echo "$LANG_MSG_ITERM_AI_SUCCESS"
      echo "$LANG_MSG_ITERM_AI"
      printf '%b\n' "$LANG_MSG_ITERM_AI_STEPS"
    else
      echo "⚠️ Échec de l'installation du plugin AI iTerm2"
    fi
    trap - EXIT
    rm -rf "$tmp_dir"
  else
    echo "$LANG_MSG_ITERM_AI_CANCEL"
  fi
fi

### The rest only runs inside iTerm2
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then

  ### OH MY ZSH
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "$LANG_MSG_INSTALLING Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✅ Oh My Zsh $LANG_MSG_INSTALLED"
  fi

  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-completions; do
    if [ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
      echo "$LANG_MSG_INSTALLING $plugin..."
      if git clone "https://github.com/zsh-users/$plugin" "$ZSH_CUSTOM/plugins/$plugin"; then
        echo "✅ $plugin $LANG_MSG_INSTALLED"
      else
        echo "⚠️ Échec de l'installation de $plugin"
      fi
    fi
  done

  backup_zshrc

  ### POWERLEVEL10K
  if ! brew list powerlevel10k &>/dev/null; then
    echo "$LANG_MSG_INSTALLING Powerlevel10k..."
    brew install powerlevel10k
    echo "✅ Powerlevel10k $LANG_MSG_INSTALLED"
  fi

  P10K_PATH="$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"
  if [ -f "$P10K_PATH" ]; then
    mkdir -p "$ZSH_CUSTOM/themes/powerlevel10k"
    ln -sf "$P10K_PATH" "$ZSH_CUSTOM/themes/powerlevel10k/powerlevel10k.zsh-theme"
    ZSH_THEME_LINE='ZSH_THEME="powerlevel10k/powerlevel10k"'
  else
    echo "$LANG_MSG_POWERLEVEL_ERROR"
    ZSH_THEME_LINE='ZSH_THEME="robbyrussell"'
  fi

  {
    echo 'export ZSH="$HOME/.oh-my-zsh"'
    echo '# Homebrew PATH'
    echo 'if [[ -x /opt/homebrew/bin/brew ]]; then'
    echo '  eval "$(/opt/homebrew/bin/brew shellenv)"'
    echo 'elif [[ -x /usr/local/bin/brew ]]; then'
    echo '  eval "$(/usr/local/bin/brew shellenv)"'
    echo 'fi'
    echo "$ZSH_THEME_LINE"
    echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)'
    echo 'source $ZSH/oh-my-zsh.sh'
    echo 'autoload -U compinit && compinit'
    echo '(( $+commands[atuin] )) && eval "$(atuin init zsh)"'
    echo '(( $+commands[direnv] )) && eval "$(direnv hook zsh)"'
    echo 'if (( $+commands[gpgconf] )); then'
    echo '  export GPG_TTY="$(tty)"'
    echo '  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"'
    echo '  gpgconf --launch gpg-agent 2>/dev/null'
    echo 'fi'
    echo 'if (( $+commands[eza] )); then'
    echo '  alias ls="eza -a --icons"'
    echo '  alias ll="eza -1a --icons"'
    echo '  alias ld="ll"'
    echo '  alias la="eza -lagh --icons"'
    echo '  alias lt="eza -a --tree --icons --level=2"'
    echo '  alias ltf="eza -a --tree --icons"'
    echo '  alias lat="eza -lagh --tree --icons"'
    echo 'fi'
  } > "$HOME/.zshrc"

  echo "$LANG_MSG_POWERLEVEL_CONFIG"

  ### ATUIN
  install_if_missing atuin

  ### CRYPTO TOOLS
  echo "🔄 Installation des outils de cryptographie..."
  for pkg in pinentry-mac gnupg; do
    install_if_missing "$pkg"
  done
  echo "✅ Installation des outils de cryptographie terminée"

  ### GPG-AGENT FOR YUBIKEY
  echo "🔐 Configuration de GPG-agent pour YubiKey..."
  mkdir -p "$HOME/.gnupg"
  chmod 700 "$HOME/.gnupg"

  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  if [ -f "$SCRIPT_DIR/config/gpg-agent.conf" ]; then
    cp "$SCRIPT_DIR/config/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf"
    chmod 600 "$HOME/.gnupg/gpg-agent.conf"
    echo "✅ Configuration GPG-agent déployée"
    gpgconf --kill gpg-agent 2>/dev/null || true
    gpgconf --launch gpg-agent 2>/dev/null || true
  else
    echo "⚠️ Fichier config/gpg-agent.conf introuvable"
  fi

  ### EZA
  install_if_missing eza

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

  ### PUBLISH_PY ALIAS
  if confirm "$LANG_MSG_PUBLISH_INSTALL"; then
    echo "$LANG_MSG_INSTALLING publish_py..."
    tmpfile=$(mktemp)
    trap 'rm -f "$tmpfile"' EXIT
    if curl -fsSL -o "$tmpfile" \
         https://raw.githubusercontent.com/ClaraVnk/python-package/main/install_publish_alias.sh; then
      chmod +x "$tmpfile"
      "$tmpfile"
      echo "✅ publishpy $LANG_MSG_INSTALLED"
    else
      echo "⚠️ Échec du téléchargement de publish_py"
    fi
    trap - EXIT
    rm -f "$tmpfile"
  else
    echo "$LANG_MSG_PUBLISH_CANCEL"
  fi

  echo "$LANG_MSG_SETUP_COMPLETE"

  if [[ "$LANG" == fr_* ]]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎯 PROCHAINES ÉTAPES - Configuration de votre espace de travail"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "1️⃣  Recharger votre configuration :"
    echo "    source ~/.zshrc"
    echo ""
    echo "2️⃣  Configurer Powerlevel10k (prompt personnalisé) :"
    echo "    p10k configure"
    echo ""
    echo "3️⃣  Configurer Atuin (historique synchronisé) :"
    echo "    atuin register -u <votre-email> -p <mot-de-passe>"
    echo "    atuin login -u <votre-email> -p <mot-de-passe>"
    echo "    atuin sync"
    echo ""
    echo "4️⃣  Configurer GPG/YubiKey :"
    echo "    gpg --card-status     # Vérifier la YubiKey"
    echo "    gpg --edit-card       # Configurer la carte"
    echo ""
    echo "5️⃣  Tester les outils installés :"
    echo "    eza -la               # Lister les fichiers avec style"
    echo "    fzf                   # Recherche floue interactive"
    echo ""
    echo "6️⃣  Outils Python disponibles :"
    echo "    black <fichier.py>    # Formater le code"
    echo "    isort <fichier.py>    # Trier les imports"
    echo "    flake8 <fichier.py>   # Linter"
    echo "    bandit <fichier.py>   # Analyse de sécurité"
    echo ""
    echo "7️⃣  Importer le thème Dracula dans iTerm2 :"
    echo "    Preferences > Profiles > Colors > Import..."
    echo "    Fichier : ~/.iterm2/themes/Dracula.itermcolors"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎯 NEXT STEPS - Configure your workspace"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "1️⃣  Reload your configuration:"
    echo "    source ~/.zshrc"
    echo ""
    echo "2️⃣  Configure Powerlevel10k (custom prompt):"
    echo "    p10k configure"
    echo ""
    echo "3️⃣  Configure Atuin (synced history):"
    echo "    atuin register -u <your-email> -p <password>"
    echo "    atuin login -u <your-email> -p <password>"
    echo "    atuin sync"
    echo ""
    echo "4️⃣  Configure GPG/YubiKey:"
    echo "    gpg --card-status     # Check YubiKey"
    echo "    gpg --edit-card       # Configure card"
    echo ""
    echo "5️⃣  Test installed tools:"
    echo "    eza -la               # List files with style"
    echo "    fzf                   # Interactive fuzzy finder"
    echo ""
    echo "6️⃣  Python tools available:"
    echo "    black <file.py>       # Format code"
    echo "    isort <file.py>       # Sort imports"
    echo "    flake8 <file.py>      # Linter"
    echo "    bandit <file.py>      # Security analysis"
    echo ""
    echo "7️⃣  Import Dracula theme in iTerm2:"
    echo "    Preferences > Profiles > Colors > Import..."
    echo "    File: ~/.iterm2/themes/Dracula.itermcolors"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  fi
fi
