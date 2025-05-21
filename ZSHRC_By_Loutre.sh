# ZSHRC By Loutre, inspired from PAPAMICA
# Environement : MACOS

set -e

### INSTALLATION DE HOMEBREW SI ABSENT
if ! command -v brew &>/dev/null; then
  echo "🔧 Installation de Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Recharge le PATH pour la session en cours
  eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
  echo "✅ Homebrew installé avec succès."
fi

### INSTALLATION DE iTerm2 SI ABSENT
if [ ! -d "/Applications/iTerm.app" ]; then
    echo "🔧 Installation de iTerm2..."
    brew install --cask iterm2
    echo "✅ iTerm2 installé avec succès."
fi

### TOUT LE RESTE NE S’EXECUTE QUE SI ON EST DANS ITERM2
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then

  ### INSTALLATION OH MY ZSH
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🔧 Installation de Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "✅ Oh My Zsh installé avec succès."
  fi
  # Chargement de Oh My Zsh
  source $HOME/.oh-my-zsh/oh-my-zsh.sh

  ### INSTALLATION POWERLEVEL10K
  if ! brew list powerlevel10k &>/dev/null; then
    echo "🔧 Installation de Powerlevel10k..."
    brew install powerlevel10k
    echo "✅ Powerlevel10k installé avec succès."
    echo "⚠️ Voulez-vous lancer la configuration de Powerlevel10k maintenant ? (y/N)"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      p10k configure
    else
      echo "⚠️ Configuration de Powerlevel10k non réalisée. Vous pouvez la relancer plus tard avec 'p10k configure'."
    fi
  fi
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
  if [ -f /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme ]; then
    source /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme
  fi
  #typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

  # 🎨 Pour appliquer le thème Dracula visuellement, installe le fichier .itermcolors depuis https://draculatheme.com/iterm
  # Ensuite, dans iTerm2 : Preferences > Profiles > Colors > Presets > Dracula
  echo "⚠️ Pour appliquer le thème Dracula dans iTerm2, importe le fichier .itermcolors disponible ici : https://draculatheme.com/iterm"
  echo "Puis dans iTerm2, va dans Preferences > Profiles > Colors > Color Presets > Import... et sélectionne Dracula."
  echo "Enfin, applique le preset Dracula dans le même menu."

  ### INSTALLATION DES PLUGINS ZSH
  # ZSH-AUTOSUGGESTIONS : https://github.com/zsh-users/zsh-autosuggestions
  if type brew &>/dev/null; then
      FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  fi

  # ZSH-SYNTAX-HIGHLIGHTING : https://github.com/zsh-users/zsh-syntax-highlighting
  # ZSH-COMPLETIONS : https://github.com/zsh-users/zsh-completions
  plugins=(zsh-autocomplete zsh-autosuggestions zsh-syntax-highlighting zsh-completions)

  autoload -Uz compinit
  compinit

  ### INSTALLATION ATUIN : https://github.com/ellie/atuin
  if ! command -v atuin &>/dev/null; then
    echo "🔧 Installation de AtuIn..."
    brew install atuin
    echo "✅ AtuIn installé avec succès."
  fi
  if [[ $- == *i* ]]; then
    eval "$(atuin init zsh)"
  fi
  if ! grep -q 'atuin init zsh' ~/.zshrc; then
    echo 'eval "$(atuin init zsh)"' >> ~/.zshrc
    echo "✅ Initialisation Atuin ajoutée à ~/.zshrc"
  fi

  ### FZF : https://github.com/junegunn/fzf
  if ! brew list fzf &>/dev/null; then
    echo "🔧 Installation de fzf..."
    brew install fzf
    echo "✅ fzf installé avec succès."
    # Optionnel : installer les fichiers de configuration fzf
    $(brew --prefix)/opt/fzf/install --all --no-bash --no-fish
  fi
  if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
  fi
  if [ -f ~/.fzf.zsh ] && ! grep -q 'source ~/.fzf.zsh' ~/.zshrc; then
    echo 'source ~/.fzf.zsh' >> ~/.zshrc
    echo "✅ Initialisation fzf ajoutée à ~/.zshrc"
  fi

  ### INSTALLATION DE PINENTRY-MAC & GNUPG
  if command -v brew &>/dev/null; then
    if ! brew list pinentry-mac &>/dev/null; then
      echo "🔧 Installation de pinentry-mac..."
      brew install pinentry-mac
      echo "✅ pinentry-mac installé avec succès."
    fi
    ### GNUPG
    if ! brew list gnupg &>/dev/null; then
      echo "🔧 Installation de gnupg..."
      brew install gnupg
      echo "✅ gnupg installé avec succès."
    fi
  fi

  ### ALIAS POUR LA YUBIKEY : https://github.com/drduh/YubiKey-Guide
  export GPG_TTY="$(tty)"
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  gpgconf --launch gpg-agent

  if ! grep -q 'GPG_TTY=' ~/.zshrc; then
    echo '# YubiKey + GPG config' >> ~/.zshrc
    echo 'export GPG_TTY="$(tty)"' >> ~/.zshrc
    echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)' >> ~/.zshrc
    echo 'gpgconf --launch gpg-agent' >> ~/.zshrc
    echo "✅ Configuration GPG/YubiKey ajoutée à ~/.zshrc"
  fi

  ### DIRENV : https://direnv.net/
  eval "$(direnv hook zsh)"
  if ! grep -q 'eval "$(direnv hook zsh)"' ~/.zshrc; then
    echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
    echo "✅ Initialisation Direnv ajoutée à ~/.zshrc"
  fi
  if ! brew list direnv &>/dev/null; then
    echo "🔧 Installation de direnv..."
    brew install direnv
    echo "✅ direnv installé avec succès."
  fi

  ### EXA : https://the.exa.website/
  if ! brew list exa &>/dev/null; then
    echo "🔧 Installation de exa..."
    brew install exa
    echo "✅ exa installé avec succès."
  fi

  # Ajout des alias exa dans ~/.zshrc uniquement s'ils sont absents
  if ! grep -q 'alias ls=' ~/.zshrc; then
    echo '# Alias exa' >> ~/.zshrc
    echo 'alias ls="exa -a --icons"' >> ~/.zshrc
    echo 'alias ll="exa -1a --icons"' >> ~/.zshrc
    echo 'alias ld="ll"' >> ~/.zshrc
    echo 'alias la="exa -lagh --icons"' >> ~/.zshrc
    echo 'alias lt="exa -a --tree --icons --level=2"' >> ~/.zshrc
    echo 'alias ltf="exa -a --tree --icons"' >> ~/.zshrc
    echo 'alias lat="exa -lagh --tree --icons"' >> ~/.zshrc
    echo "✅ Alias exa ajoutés à ~/.zshrc"
  fi

  alias ls="exa -a --icons"                   # short, multi-line
  alias ll="exa -1a --icons"                  # list, 1 per line
  alias ld="ll"                               # ^^^, NOTE: Trying to move to this for alternate hand commands
  alias la="exa -lagh --icons"                  # list with info
  alias lt="exa -a --tree --icons --level=2"  # list with tree level 2
  alias ltf="exa -a --tree --icons"           # list with tree
  alias lat="exa -lagh --tree --icons"          # list with info and tree

  ### RACCOURCIS