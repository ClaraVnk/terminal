# ZSHRC By Loutre, inspired from PAPAMICA
# Environement : MACOS

# Détection de la langue du système
if [[ "$LANG" == fr_* ]]; then
  LANG_MSG_SCRIPT_RELAUNCH="🔄 Relance du script en utilisant Zsh..."
  LANG_MSG_INSTALLING="🔧 Installation de"
  LANG_MSG_INSTALLED="✅ installé avec succès."
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

# Donne les droits d'exécution au script
chmod +x "$0"

# Ensure the script is running under Zsh
if [ -z "$ZSH_VERSION" ]; then
  echo "$LANG_MSG_SCRIPT_RELAUNCH"
  exec zsh "$0"
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

backup_zshrc() {
  if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup_$(date +%Y%m%d_%H%M%S)
  fi
}

### INSTALLATION DE HOMEBREW SI ABSENT
if ! command -v brew &>/dev/null; then
  echo "$LANG_MSG_INSTALLING Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Configuration du PATH pour Homebrew
  if [[ -f /opt/homebrew/bin/brew ]]; then
    # Pour Apple Silicon (M1/M2)
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
  elif [[ -f /usr/local/bin/brew ]]; then
    # Pour Intel Mac
    eval "$(/usr/local/bin/brew shellenv)"
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
  fi
  
  echo "✅ Homebrew $LANG_MSG_INSTALLED"
fi

### INSTALLATION DE iTerm2 SI ABSENT
if [ ! -d "/Applications/iTerm.app" ]; then
    echo "$LANG_MSG_INSTALLING iTerm2..."
    brew install --cask iterm2
    echo "✅ iTerm2 $LANG_MSG_INSTALLED"
    
    # Installation du thème Dracula
    echo "$LANG_MSG_ITERM_THEME"
    mkdir -p ~/.iterm2/themes
    curl -L "https://raw.githubusercontent.com/dracula/iterm/master/Dracula.itermcolors" -o ~/.iterm2/themes/Dracula.itermcolors
    echo "$LANG_MSG_ITERM_THEME_SUCCESS"
    echo -e "$LANG_MSG_ITERM_THEME_STEPS"
fi

### INSTALLATION DU PLUGIN AI ITERM2
if [ ! -d "/Applications/iTerm2 AI Plugin.app" ]; then
    echo "$LANG_MSG_ITERM_AI_PROMPT"
    read -r answer
    if [[ "$LANG" == fr_* && "$answer" =~ ^[oO]$ ]] || [[ "$LANG" != fr_* && "$answer" =~ ^[yY]$ ]]; then
        echo "$LANG_MSG_ITERM_AI_INSTALL"
        # Création d'un dossier temporaire
        tmp_dir=$(mktemp -d)
        # Téléchargement et installation du plugin
        curl -L "https://iterm2.com/downloads/ai/iTerm2%20AI%20Plugin.zip" -o "$tmp_dir/iterm2_ai_plugin.zip"
        unzip -q "$tmp_dir/iterm2_ai_plugin.zip" -d "/Applications/"
        # Nettoyage
        rm -rf "$tmp_dir"
        echo "$LANG_MSG_ITERM_AI_SUCCESS"
        echo "$LANG_MSG_ITERM_AI"
        echo -e "$LANG_MSG_ITERM_AI_STEPS"
    else
        echo "$LANG_MSG_ITERM_AI_CANCEL"
    fi
fi

### TOUT LE RESTE NE S'EXECUTE QUE SI ON EST DANS ITERM2
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then

  ### INSTALLATION OH MY ZSH
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "$LANG_MSG_INSTALLING Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✅ Oh My Zsh $LANG_MSG_INSTALLED"
  fi

  # Installation des plugins Oh My Zsh
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  
  # zsh-autosuggestions
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "$LANG_MSG_INSTALLING zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    echo "✅ zsh-autosuggestions $LANG_MSG_INSTALLED"
  fi

  # zsh-syntax-highlighting
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "$LANG_MSG_INSTALLING zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    echo "✅ zsh-syntax-highlighting $LANG_MSG_INSTALLED"
  fi

  # zsh-completions
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
    echo "$LANG_MSG_INSTALLING zsh-completions..."
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
    echo "✅ zsh-completions $LANG_MSG_INSTALLED"
  fi

  # Création/Sauvegarde du .zshrc
  backup_zshrc

  ### INSTALLATION POWERLEVEL10K
  if ! brew list powerlevel10k &>/dev/null; then
    echo "$LANG_MSG_INSTALLING Powerlevel10k..."
    brew install powerlevel10k
    echo "✅ Powerlevel10k $LANG_MSG_INSTALLED"
  fi

  # Configuration de base Oh My Zsh et Powerlevel10k
  {
    # Configuration de base
    echo 'export ZSH="$HOME/.oh-my-zsh"'
    
    # Homebrew PATH (doit être avant tout le reste)
    echo '# Homebrew PATH configuration'
    echo 'if [[ -x /opt/homebrew/bin/brew ]]; then'
    echo '  eval "$(/opt/homebrew/bin/brew shellenv)"'
    echo 'elif [[ -x /usr/local/bin/brew ]]; then'
    echo '  eval "$(/usr/local/bin/brew shellenv)"'
    echo 'fi'

    # Configuration Powerlevel10k
    P10K_PATH="$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"
    if [ -f "$P10K_PATH" ]; then
      # Création du lien symbolique pour le thème dans Oh My Zsh
      mkdir -p "$ZSH_CUSTOM/themes/powerlevel10k"
      ln -sf "$P10K_PATH" "$ZSH_CUSTOM/themes/powerlevel10k/powerlevel10k.zsh-theme"
      echo 'ZSH_THEME="powerlevel10k/powerlevel10k"'
      echo 'alias p10k="$(brew --prefix)/share/powerlevel10k/powerlevel10k"'
    else
      echo "$LANG_MSG_POWERLEVEL_ERROR"
      echo 'ZSH_THEME="robbyrussell"'  # Thème par défaut si powerlevel10k n'est pas trouvé
    fi
    
    # Oh My Zsh plugins
    echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)'
    
    # Source Oh My Zsh
    echo 'source $ZSH/oh-my-zsh.sh'
    
    # Activation des completions
    echo 'autoload -U compinit && compinit'

    # Configurations des outils
    echo '# Tool configurations'
    echo 'if (( $+commands[atuin] )); then'
    echo '  eval "$(atuin init zsh)"'
    echo 'fi'

    echo 'if (( $+commands[direnv] )); then'
    echo '  eval "$(direnv hook zsh)"'
    echo 'fi'

    echo 'if (( $+commands[gpgconf] )); then'
    echo '  export GPG_TTY="$(tty)"'
    echo '  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"'
    echo '  gpgconf --launch gpg-agent 2>/dev/null'
    echo 'fi'

    # Alias eza
    echo 'if (( $+commands[eza] )); then'
    echo '  alias ls="eza -a --icons"'
    echo '  alias ll="eza -1a --icons"'
    echo '  alias ld="ll"'
    echo '  alias la="eza -lagh --icons"'
    echo '  alias lt="eza -a --tree --icons --level=2"'
    echo '  alias ltf="eza -a --tree --icons"'
    echo '  alias lat="eza -lagh --tree --icons"'
    echo 'fi'
  } > ~/.zshrc

  echo "$LANG_MSG_POWERLEVEL_CONFIG"

  ### INSTALLATION ATUIN
  echo "🔄 Installation d'Atuin..."
  install_if_missing atuin
  if [[ $? -eq 0 ]]; then
    if [[ $- == *i* ]]; then
      eval "$(atuin init zsh)"
    fi
  fi

  ### INSTALLATION DE PINENTRY-MAC & GNUPG
  echo "🔄 Installation des outils de cryptographie..."
  for pkg in pinentry-mac gnupg; do
    install_if_missing "$pkg"
  done
  echo "✅ Installation des outils de cryptographie terminée"

  ### INSTALLATION EZA
  echo "🔄 Installation d'Eza..."
  install_if_missing eza

  # Ajout des alias eza
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
  echo "✅ Configuration d'Eza terminée"

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
    echo "✅ publishpy $LANG_MSG_INSTALLED"
  else
    echo "$LANG_MSG_PUBLISH_CANCEL"
  fi

  echo "$LANG_MSG_SETUP_COMPLETE"
  
  # Ajout des messages pour le rechargement
  if [[ "$LANG" == fr_* ]]; then
    echo "💡 Pour appliquer les changements, vous pouvez :"
    echo "   - Soit ouvrir un nouveau terminal"
    echo "   - Soit taper 'source ~/.zshrc' dans le terminal actuel"
  else
    echo "💡 To apply changes, you can either:"
    echo "   - Open a new terminal"
    echo "   - Type 'source ~/.zshrc' in the current terminal"
  fi
fi