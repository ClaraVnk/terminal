#!/usr/bin/env bash
set -e

### INSTALL HOMEBREW (Linuxbrew) IF MISSING
if ! command -v brew &>/dev/null; then
  echo "🔧 Installing Homebrew (Linuxbrew)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Reload PATH for the current session
  test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
  test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  echo "✅ Homebrew installed successfully."
fi

### UPDATE BREW
echo "🔄 Updating Homebrew packages..."
brew update

### INSTALL PACKAGES via Brew

# Exa → eza
if ! brew list eza &>/dev/null; then
  echo "🔧 Installing eza..."
  brew install eza
  echo "✅ eza installed successfully."
fi

# AtuIn
if ! command -v atuin &>/dev/null; then
  echo "🔧 Installing AtuIn..."
  brew install atuin
  echo "✅ AtuIn installed successfully."
fi

# fzf
if ! brew list fzf &>/dev/null; then
  echo "🔧 Installing fzf..."
  brew install fzf
  echo "✅ fzf installed successfully."
fi

# direnv
if ! brew list direnv &>/dev/null; then
  echo "🔧 Installing direnv..."
  brew install direnv
  echo "✅ direnv installed successfully."
fi

# pinentry (Linux version)
if ! brew list pinentry &>/dev/null; then
  echo "🔧 Installing pinentry..."
  brew install pinentry
  echo "✅ pinentry installed successfully."
fi

# gnupg
if ! brew list gnupg &>/dev/null; then
  echo "🔧 Installing gnupg..."
  brew install gnupg
  echo "✅ gnupg installed successfully."
fi

# Add eza aliases to ~/.bashrc only if missing
if ! grep -q 'alias ls=' ~/.bashrc; then
  echo '# eza aliases' >> ~/.bashrc
  echo 'alias ls="eza -a --icons"' >> ~/.bashrc
  echo 'alias ll="eza -1a --icons"' >> ~/.bashrc
  echo 'alias ld="ll"' >> ~/.bashrc
  echo 'alias la="eza -lagh --icons"' >> ~/.bashrc
  echo 'alias lt="eza -a --tree --icons --level=2"' >> ~/.bashrc
  echo 'alias ltf="eza -a --tree --icons"' >> ~/.bashrc
  echo 'alias lat="eza -lagh --tree --icons"' >> ~/.bashrc
  echo "✅ eza aliases added to ~/.bashrc"
fi

# Initialize atuin in bashrc
if ! grep -q 'atuin init bash' ~/.bashrc; then
  echo 'eval "$(atuin init bash)"' >> ~/.bashrc
  echo "✅ AtuIn initialization added to ~/.bashrc"
fi

# Initialize fzf in bashrc
if ! grep -q 'source ~/.fzf.bash' ~/.bashrc; then
  echo '[ -f ~/.fzf.bash ] && source ~/.fzf.bash' >> ~/.bashrc
  echo "✅ fzf initialization added to ~/.bashrc"
fi

# Initialize direnv in bashrc
if ! grep -q 'eval "$(direnv hook bash)"' ~/.bashrc; then
  echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
  echo "✅ direnv initialization added to ~/.bashrc"
fi

# GPG / pinentry configuration for YubiKey
if ! grep -q 'GPG_TTY=' ~/.bashrc; then
  echo '# YubiKey + GPG config' >> ~/.bashrc
  echo 'export GPG_TTY=$(tty)' >> ~/.bashrc
  echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)' >> ~/.bashrc
  echo 'gpgconf --launch gpg-agent' >> ~/.bashrc
  echo "✅ GPG/YubiKey configuration added to ~/.bashrc"
fi

echo "🎉 Setup complete. Reload your shell with: source ~/.bashrc"