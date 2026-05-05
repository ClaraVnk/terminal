#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
  echo "⚠️ Usage: $0 path_to_backup_archive.tar.gz"
  exit 1
fi

backup_archive="$1"

if [ ! -f "$backup_archive" ]; then
  echo "❌ Archive not found: $backup_archive"
  exit 1
fi

if [ ! -r "$backup_archive" ]; then
  echo "❌ Archive is not readable: $backup_archive"
  exit 1
fi

restore_dir="$HOME/migration_restore_$(date +%Y%m%d_%H%M%S)"

cleanup() {
  rm -rf "$restore_dir"
}
trap cleanup EXIT

# 1. Extract archive
mkdir -p "$restore_dir"
echo "📂 Extracting archive $backup_archive to $restore_dir..."
tar -xzf "$backup_archive" -C "$restore_dir"
echo "✔️ Archive extracted."

# 2. Restore dotfiles
dotfiles=(.zshrc .vimrc .gitconfig .bashrc)
echo "📝 Restoring dotfiles..."
for file in "${dotfiles[@]}"; do
  if [ -f "$restore_dir/$file" ]; then
    cp "$restore_dir/$file" "$HOME/"
    echo "✔️ Restored $file"
  else
    echo "⚠️ $file not found in backup, skipping."
  fi
done

# 3. Install Homebrew packages
if command -v brew &>/dev/null; then
  if [ -f "$restore_dir/brew_packages.txt" ]; then
    echo "🍺 Installing Homebrew formula packages..."
    xargs brew install < "$restore_dir/brew_packages.txt"
    echo "✔️ Homebrew formula packages installed."
  fi
  if [ -f "$restore_dir/brew_cask_packages.txt" ]; then
    echo "🍺 Installing Homebrew cask packages..."
    xargs brew install --cask < "$restore_dir/brew_cask_packages.txt"
    echo "✔️ Homebrew cask packages installed."
  fi
fi

# 4. Install pip packages
if command -v pip3 &>/dev/null; then
  if [ -f "$restore_dir/pip_packages.txt" ]; then
    echo "🐍 Installing pip packages..."
    pip3 install -r "$restore_dir/pip_packages.txt"
    echo "✔️ pip packages installed."
  fi
fi

# 5. Install npm global packages
if command -v npm &>/dev/null; then
  if [ -f "$restore_dir/npm_packages.txt" ]; then
    echo "📦 Installing npm global packages..."
    grep -E '(├|└)' "$restore_dir/npm_packages.txt" \
      | awk '{print $2}' \
      | grep -v '^npm@' \
      | sed 's/@[^@]*$//' \
      | xargs -r npm install -g
    echo "✔️ npm packages installed."
  fi
fi

# 6. Restore SSH keys (with confirmation)
read -r -p "🔐 Restore your SSH keys? (y/N) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  if [ -d "$restore_dir/.ssh" ]; then
    mkdir -p "$HOME/.ssh"
    cp -rp "$restore_dir/.ssh/." "$HOME/.ssh/"
    chmod 700 "$HOME/.ssh"
    find "$HOME/.ssh" -name "*.pub" -exec chmod 644 {} \;
    find "$HOME/.ssh" -name "id_*" ! -name "*.pub" -exec chmod 600 {} \;
    chmod 600 "$HOME/.ssh/config" 2>/dev/null || true
    chmod 600 "$HOME/.ssh/authorized_keys" 2>/dev/null || true
    chmod 600 "$HOME/.ssh/known_hosts" 2>/dev/null || true
    echo "✔️ SSH keys restored."
  else
    echo "⚠️ No SSH keys found in backup."
  fi
else
  echo "ℹ️ SSH keys restoration skipped."
fi

# 7. Restore global git config
if [ -f "$restore_dir/git_global_config.txt" ]; then
  echo "🔧 Restoring git global config..."
  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    key="${line%%=*}"
    value="${line#*=}"
    key="${key#"${key%%[! ]*}"}"
    key="${key%"${key##*[! ]}"}"
    # Skip aliases (values can contain shell commands with !)
    if [[ "$key" =~ ^alias\. ]]; then
      echo "⚠️  Skipping git alias (security): $key"
      continue
    fi
    # Validate key format: section.name or section.subsection.name
    if [[ ! "$key" =~ ^[a-zA-Z][a-zA-Z0-9-]*(\.[a-zA-Z0-9._/-]+)+$ ]]; then
      echo "⚠️  Skipping invalid git config key: $key"
      continue
    fi
    git config --global "$key" "$value"
  done < "$restore_dir/git_global_config.txt"
  echo "✔️ Git global config restored."
fi

echo "🎉 Restore completed. Please restart your terminal session."
