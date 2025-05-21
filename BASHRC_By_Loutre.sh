#!/usr/bin/env bash
set -e

### INSTALLATION DE HOMEBREW (Linuxbrew) SI ABSENT
if ! command -v brew &>/dev/null; then
  echo "🔧 Installation de Homebrew (Linuxbrew)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Recharge le PATH pour la session en cours
  test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
  test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  echo "✅ Homebrew installé avec succès."
fi

### MISE À JOUR DE BREW
echo "🔄 Mise à jour des paquets Homebrew..."
brew update

### INSTALLATION DE PAQUETS via Brew

# Exa → eza
if ! brew list eza &>/dev/null; then
  echo "🔧 Installation de eza..."
  brew install eza
  echo "✅ eza installé avec succès."
fi

# AtuIn
if ! command -v atuin &>/dev/null; then
  echo "🔧 Installation de AtuIn..."
  brew install atuin
  echo "✅ AtuIn installé avec succès."
fi

# fzf
if ! brew list fzf &>/dev/null; then
  echo "🔧 Installation de fzf..."
  brew install fzf
  echo "✅ fzf installé avec succès."
fi

# direnv
if ! brew list direnv &>/dev/null; then
  echo "🔧 Installation de direnv..."
  brew install direnv
  echo "✅ direnv installé avec succès."
fi

# pinentry (Linux version)
if ! brew list pinentry &>/dev/null; then
  echo "🔧 Installation de pinentry..."
  brew install pinentry
  echo "✅ pinentry installé avec succès."
fi

# gnupg
if ! brew list gnupg &>/dev/null; then
  echo "🔧 Installation de gnupg..."
  brew install gnupg
  echo "✅ gnupg installé avec succès."
fi

# Ajout des alias eza dans ~/.bashrc uniquement s'ils sont absents
if ! grep -q 'alias ls=' ~/.bashrc; then
  echo '# Alias eza' >> ~/.bashrc
  echo 'alias ls="eza -a --icons"' >> ~/.bashrc
  echo 'alias ll="eza -1a --icons"' >> ~/.bashrc
  echo 'alias ld="ll"' >> ~/.bashrc
  echo 'alias la="eza -lagh --icons"' >> ~/.bashrc
  echo 'alias lt="eza -a --tree --icons --level=2"' >> ~/.bashrc
  echo 'alias ltf="eza -a --tree --icons"' >> ~/.bashrc
  echo 'alias lat="eza -lagh --tree --icons"' >> ~/.bashrc
  echo "✅ Alias eza ajoutés à ~/.bashrc"
fi

# Initialisation atuin dans bashrc
if ! grep -q 'atuin init bash' ~/.bashrc; then
  echo 'eval "$(atuin init bash)"' >> ~/.bashrc
  echo "✅ Initialisation AtuIn ajoutée à ~/.bashrc"
fi

# Initialisation fzf dans bashrc
if ! grep -q 'source ~/.fzf.bash' ~/.bashrc; then
  echo '[ -f ~/.fzf.bash ] && source ~/.fzf.bash' >> ~/.bashrc
  echo "✅ Initialisation fzf ajoutée à ~/.bashrc"
fi

# Initialisation direnv dans bashrc
if ! grep -q 'eval "$(direnv hook bash)"' ~/.bashrc; then
  echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
  echo "✅ Initialisation direnv ajoutée à ~/.bashrc"
fi

# Configuration GPG / pinentry pour YubiKey
if ! grep -q 'GPG_TTY=' ~/.bashrc; then
  echo '# YubiKey + GPG config' >> ~/.bashrc
  echo 'export GPG_TTY=$(tty)' >> ~/.bashrc
  echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)' >> ~/.bashrc
  echo 'gpgconf --launch gpg-agent' >> ~/.bashrc
  echo "✅ Configuration GPG/YubiKey ajoutée à ~/.bashrc"
fi

echo "🎉 Configuration terminée. Recharge ton shell avec : source ~/.bashrc"