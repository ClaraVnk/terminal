# ZSHRC By Loutre, inspired by PAPAMICA
# Environment: macOS

set -e

# Ensure the script is running under Zsh
if [ -z "$ZSH_VERSION" ]; then
  echo "🔄 Re-running this script using Zsh..."
  exec zsh "$0"
fi

install_if_missing() {
  local package=$1
  if ! brew list "$package" &>/dev/null; then
    echo "🔧 Installing $package..."
    brew install "$package"
    echo "✅ $package installed successfully."
  fi
}

backup_zshrc() {
  if [ -f "$HOME/.zshrc" ]; then
    local backup_file="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
    cp "$HOME/.zshrc" "$backup_file"
    echo "✅ Backup of .zshrc created at $backup_file"
  fi
}

check_internet() {
  echo "🌐 Checking internet connection..."
  if ! ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
    echo "❌ No internet connection detected. Please check your network and try again."
    exit 1
  fi
  echo "✅ Internet connection is active."
}

### INSTALL HOMEBREW IF MISSING
check_internet
if ! command -v brew &>/dev/null; then
  echo "🔧 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Reload PATH for current session
  eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
  echo "✅ Homebrew installed successfully."
fi

### INSTALL iTerm2 IF MISSING
check_internet
if [ ! -d "/Applications/iTerm.app" ]; then
  install_if_missing "iterm2"
fi

### THE REST RUNS ONLY IF USING iTerm2
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then

  ### INSTALL OH MY ZSH
  check_internet
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🔧 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "✅ Oh My Zsh installed successfully."
  fi
  # Load Oh My Zsh
  source $HOME/.oh-my-zsh/oh-my-zsh.sh

  ### INSTALL POWERLEVEL10K
  check_internet
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
  compaudit | xargs chmod -R go-w 2>/dev/null
  compinit

  ### ATUIN INSTALLATION: https://github.com/ellie/atuin
  check_internet
  install_if_missing "atuin"
  if [[ $- == *i* ]]; then
    eval "$(atuin init zsh)"
  fi
  backup_zshrc
  if ! grep -q 'atuin init zsh' ~/.zshrc; then
    echo 'eval "$(atuin init zsh)"' >> ~/.zshrc
    echo "✅ AtuIn initialization added to ~/.zshrc"
  fi

  ### FZF: https://github.com/junegunn/fzf
  check_internet
  install_if_missing "fzf"
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
  backup_zshrc
  if [ -f ~/.fzf.zsh ] && ! grep -q 'source ~/.fzf.zsh' ~/.zshrc; then
    echo 'source ~/.fzf.zsh' >> ~/.zshrc
    echo "✅ fzf initialization added to ~/.zshrc"
  fi

  ### PINENTRY-MAC & GNUPG INSTALLATION
  check_internet
  if command -v brew &>/dev/null; then
    install_if_missing "pinentry-mac"
    install_if_missing "gnupg"
  fi

  ### YUBIKEY ALIASES: https://github.com/drduh/YubiKey-Guide
  export GPG_TTY="$(tty)"
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  gpgconf --launch gpg-agent

  backup_zshrc
  if ! grep -q 'GPG_TTY=' ~/.zshrc; then
    echo '# YubiKey + GPG config' >> ~/.zshrc
    echo 'export GPG_TTY="$(tty)"' >> ~/.zshrc
    echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)' >> ~/.zshrc
    echo 'gpgconf --launch gpg-agent' >> ~/.zshrc
    echo "✅ GPG/YubiKey configuration added to ~/.zshrc"
  fi

  ### DIRENV: https://direnv.net/
  backup_zshrc
  if ! grep -q 'eval "$(direnv hook zsh)"' ~/.zshrc; then
    echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
    echo "✅ Direnv initialization added to ~/.zshrc"
  fi
  check_internet
  install_if_missing "direnv"
  eval "$(direnv hook zsh)"

  ### EZA: https://eza.rocks/
  check_internet
  install_if_missing "eza"

  # Add eza aliases to ~/.zshrc only if missing (checks all aliases)
  backup_zshrc
  if ! grep -q 'alias ls="eza -a --icons"' ~/.zshrc || ! grep -q 'alias ll="eza -1a --icons"' ~/.zshrc || ! grep -q 'alias ld="ll"' ~/.zshrc || ! grep -q 'alias la="eza -lagh --icons"' ~/.zshrc || ! grep -q 'alias lt="eza -a --tree --icons --level=2"' ~/.zshrc || ! grep -q 'alias ltf="eza -a --tree --icons"' ~/.zshrc || ! grep -q 'alias lat="eza -lagh --tree --icons"' ~/.zshrc; then
    echo '# Alias eza' >> ~/.zshrc
    echo 'alias ls="eza -a --icons"' >> ~/.zshrc
    echo 'alias ll="eza -1a --icons"' >> ~/.zshrc
    echo 'alias ld="ll"' >> ~/.zshrc
    echo 'alias la="eza -lagh --icons"' >> ~/.zshrc
    echo 'alias lt="eza -a --tree --icons --level=2"' >> ~/.zshrc
    echo 'alias ltf="eza -a --tree --icons"' >> ~/.zshrc
    echo 'alias lat="eza -lagh --tree --icons"' >> ~/.zshrc
    echo "✅ eza aliases added to ~/.zshrc"
  fi

  alias ls="eza -a --icons"                   # short, multi-line
  alias ll="eza -1a --icons"                  # list, 1 per line
  alias ld="ll"                               # ^^^, NOTE: Trying to move to this for alternate hand commands
  alias la="eza -lagh --icons"                # list with info
  alias lt="eza -a --tree --icons --level=2" # list with tree level 2
  alias ltf="eza -a --tree --icons"           # list with tree
  alias lat="eza -lagh --tree --icons"        # list with info and tree

  ### INSTALL PYTHON PACKAGE ALIAS SCRIPT
  echo "Would you like to install the publish_py script to automate Python package publishing? (y/N)"
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    check_internet
    echo "🔧 Installing publish_py script..."
    tmpfile=$(mktemp)
    curl -L -o "$tmpfile" https://raw.githubusercontent.com/ClaraVnk/python-package/main/install_publish_alias_en.sh
    chmod +x "$tmpfile"
    "$tmpfile"
    rm -f "$tmpfile"
    source ~/.zshrc
    echo "✅ publishpy alias added to ~/.zshrc"
  else
    echo "⚠️ publish_py script installation skipped."
  fi

  echo "🎉 Setup completed!"
fi