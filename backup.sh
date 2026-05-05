#!/usr/bin/env bash

set -e

timestamp="$(date +%Y%m%d_%H%M%S)"
backup_dir="$HOME/migration_backup_$timestamp"
archive_file="$HOME/migration_backup_$timestamp.tar.gz"

cleanup() {
  local exit_code=$?
  rm -rf "$backup_dir"
  if [ $exit_code -ne 0 ]; then
    rm -f "$archive_file"
    echo "❌ Backup failed, temporary files cleaned up."
  fi
}
trap cleanup EXIT

mkdir -p "$backup_dir"
echo "📁 Backup directory created at $backup_dir"

# 1. Dotfiles
dotfiles=(.zshrc .vimrc .gitconfig .bashrc)
echo "📝 Backing up dotfiles..."
for file in "${dotfiles[@]}"; do
  if [ -f "$HOME/$file" ]; then
    cp "$HOME/$file" "$backup_dir/"
    echo "✔️  $file backed up."
  else
    echo "⚠️  $file not found, skipping."
  fi
done

# 2. Homebrew packages
if command -v brew &>/dev/null; then
  echo "🍺 Exporting Homebrew packages list..."
  brew list --formula > "$backup_dir/brew_packages.txt"
  brew list --cask > "$backup_dir/brew_cask_packages.txt"
  echo "✔️  Homebrew packages list saved."
fi

# 3. pip packages
if command -v pip3 &>/dev/null; then
  echo "🐍 Exporting pip packages list..."
  pip3 freeze > "$backup_dir/pip_packages.txt"
  echo "✔️  pip packages list saved."
fi

# 4. npm global packages
if command -v npm &>/dev/null; then
  echo "📦 Exporting npm global packages list..."
  npm list -g --depth=0 > "$backup_dir/npm_packages.txt"
  echo "✔️  npm packages list saved."
fi

# 5. SSH keys (with confirmation, permissions preserved)
read -r -p "🔐 Do you want to backup your SSH keys? (y/N) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  mkdir -p "$backup_dir/.ssh"
  cp -rp "$HOME/.ssh/." "$backup_dir/.ssh/"
  echo "✔️  SSH keys backed up."
else
  echo "ℹ️  SSH keys backup skipped."
fi

# 6. Global git config
if git config --global --list &>/dev/null; then
  echo "🔧 Exporting global git configuration..."
  git config --global --list > "$backup_dir/git_global_config.txt"
  echo "✔️  Git global config saved."
else
  echo "⚠️  No global git config found, skipping."
fi

# 7. Create archive
echo "📦 Creating archive..."
tar -czf "$archive_file" -C "$backup_dir" .
echo "📦 Backup archive created at $archive_file"
echo "🎉 Backup completed successfully!"
