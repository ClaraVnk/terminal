# ZSHRC By Loutre, inspired by PAPAMICA
# Environment: macOS

set -e

# Ensure the script is running under Zsh
if [ -z "$ZSH_VERSION" ]; then
  echo "🔄 Re-running this script using Zsh..."
  exec zsh "$0"
fi

### INSTALL HOMEBREW IF MISSING
if ! command -v brew &>/dev/null; then
  echo "🔧 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Reload PATH for current session
  eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
  echo "✅ Homebrew installed successfully."
fi

### INSTALL iTerm2 IF MISSING
if [ ! -d "/Applications/iTerm.app" ]; then
  echo "🔧 Installing iTerm2..."
  brew install --cask iterm2
  echo "✅ iTerm2 installed successfully."
fi

### THE REST RUNS ONLY IF USING iTerm2
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then

  ### INSTALL OH MY ZSH
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🔧 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "✅ Oh My Zsh installed successfully."
  fi
  # Load Oh My Zsh
  source $HOME/.oh-my-zsh/oh-my-zsh.sh

  ### INSTALL POWERLEVEL10K
  if ! brew list powerlevel10k &>/dev/null; then
    echo "🔧 Installing Powerlevel10k..."
    brew install powerlevel10k
    echo "✅ Powerlevel10k installed successfully."
    echo "⚠️ Would you like to configure Powerlevel10k now? (y/N)"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      p10k configure
    else
      echo "⚠️ Powerlevel10k configuration skipped. You can run 'p10k configure' later."
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

  # 🎨 To apply the Dracula color scheme visually, download the .itermcolors file from https://draculatheme.com/iterm
  # Then in iTerm2: Preferences > Profiles > Colors > Presets > Dracula
  echo "⚠️ To apply the Dracula theme in iTerm2, import the .itermcolors file from: https://draculatheme.com/iterm"
  echo "Then in iTerm2, go to Preferences > Profiles > Colors > Color Presets > Import... and select Dracula."
  echo "Finally, apply the Dracula preset in the same menu."

  ### ZSH PLUGINS INSTALLATION
  # ZSH-AUTOSUGGESTIONS: https://github.com/zsh-users/zsh-autosuggestions
  if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  fi

  # ZSH-SYNTAX-HIGHLIGHTING: https://github.com/zsh-users/zsh-syntax-highlighting
  # ZSH-COMPLETIONS: https://github.com/zsh-users/zsh-completions
  plugins=(zsh-autosuggestions zsh-syntax-highlighting zsh-completions)

  autoload -Uz compinit
  compinit

  ### ATUIN INSTALLATION: https://github.com/ellie/atuin
  if ! command -v atuin &>/dev/null; then
    echo "🔧 Installing AtuIn..."
    brew install atuin
    echo "✅ AtuIn installed successfully."
  fi
  if [[ $- == *i* ]]; then
    eval "$(atuin init zsh)"
  fi
  if ! grep -q 'atuin init zsh' ~/.zshrc; then
    echo 'eval "$(atuin init zsh)"' >> ~/.zshrc
    echo "✅ AtuIn initialization added to ~/.zshrc"
  fi

  ### FZF: https://github.com/junegunn/fzf
  if ! brew list fzf &>/dev/null; then
    echo "🔧 Installing fzf..."
    brew install fzf
    echo "✅ fzf installed successfully."
    # Optional: install fzf configuration scripts
    $(brew --prefix)/opt/fzf/install --all --no-bash --no-fish
  fi
  if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
  fi
  if [ -f ~/.fzf.zsh ] && ! grep -q 'source ~/.fzf.zsh' ~/.zshrc; then
    echo 'source ~/.fzf.zsh' >> ~/.zshrc
    echo "✅ fzf initialization added to ~/.zshrc"
  fi

  ### PINENTRY-MAC & GNUPG INSTALLATION
  if command -v brew &>/dev/null; then
    if ! brew list pinentry-mac &>/dev/null; then
      echo "🔧 Installing pinentry-mac..."
      brew install pinentry-mac
      echo "✅ pinentry-mac installed successfully."
    fi
    if ! brew list gnupg &>/dev/null; then
      echo "🔧 Installing gnupg..."
      brew install gnupg
      echo "✅ gnupg installed successfully."
    fi
  fi

  ### YUBIKEY ALIASES: https://github.com/drduh/YubiKey-Guide
  export GPG_TTY="$(tty)"
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  gpgconf --launch gpg-agent

  if ! grep -q 'GPG_TTY=' ~/.zshrc; then
    echo '# YubiKey + GPG config' >> ~/.zshrc
    echo 'export GPG_TTY="$(tty)"' >> ~/.zshrc
    echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)' >> ~/.zshrc
    echo 'gpgconf --launch gpg-agent' >> ~/.zshrc
    echo "✅ GPG/YubiKey configuration added to ~/.zshrc"
  fi

  ### DIRENV: https://direnv.net/
  eval "$(direnv hook zsh)"
  if ! grep -q 'eval "$(direnv hook zsh)"' ~/.zshrc; then
    echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
    echo "✅ Direnv initialization added to ~/.zshrc"
  fi
  if ! brew list direnv &>/dev/null; then
    echo "🔧 Installing direnv..."
    brew install direnv
    echo "✅ direnv installed successfully."
  fi

  ### EXA: https://the.exa.website/
  if ! brew list exa &>/dev/null; then
    echo "🔧 Installing exa..."
    brew install exa
    echo "✅ exa installed successfully."
  fi

  # Add exa aliases to ~/.zshrc only if missing
  if ! grep -q 'alias ls=' ~/.zshrc; then
    echo '# Alias exa' >> ~/.zshrc
    echo 'alias ls="exa -a --icons"' >> ~/.zshrc
    echo 'alias ll="exa -1a --icons"' >> ~/.zshrc
    echo 'alias ld="ll"' >> ~/.zshrc
    echo 'alias la="exa -lagh --icons"' >> ~/.zshrc
    echo 'alias lt="exa -a --tree --icons --level=2"' >> ~/.zshrc
    echo 'alias ltf="exa -a --tree --icons"' >> ~/.zshrc
    echo 'alias lat="exa -lagh --tree --icons"' >> ~/.zshrc
    echo "✅ exa aliases added to ~/.zshrc"
  fi

  alias ls="exa -a --icons"                   # short, multi-line
  alias ll="exa -1a --icons"                  # list, 1 per line
  alias ld="ll"                               # ^^^, NOTE: Trying to move to this for alternate hand commands
  alias la="exa -lagh --icons"                # list with info
  alias lt="exa -a --tree --icons --level=2" # list with tree level 2
  alias ltf="exa -a --tree --icons"           # list with tree
  alias lat="exa -lagh --tree --icons"        # list with info and tree

  ### INSTALL PYTHON PACKAGE ALIAS SCRIPT
  echo "Would you like to install the publish_py script to automate Python package publishing? (y/N)"
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "🔧 Installing publish_py script..."
    curl -L -o ~/install_publish_alias.sh https://raw.githubusercontent.com/ClaraVnk/python-package/main/install_publish_alias_en.sh
    chmod +x ~/install_publish_alias_en.sh
    ~/install_publish_alias_en.sh
    source ~/.zshrc
    echo "✅ publish_py alias added to ~/.zshrc"
  else
    echo "⚠️ publish_py script installation skipped."
  fi

  echo "🎉 Setup completed!"
  fi