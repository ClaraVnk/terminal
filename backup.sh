#!/usr/bin/env bash

set -e

# Variables
timestamp="$(date +%Y%m%d_%H%M%S)"
backup_dir="$HOME/migration_backup_$timestamp"
mkdir -p "$backup_dir"
echo "📁 Backup directory created at $backup_dir"

# 1. Copier les dotfiles
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

# 2. Exporter la liste des paquets Homebrew
if command -v brew &>/dev/null; then
  echo "🍺 Exporting Homebrew packages list..."
  brew list --formula > "$backup_dir/brew_packages.txt"
  brew list --cask > "$backup_dir/brew_cask_packages.txt"
  echo "✔️  Homebrew packages list saved."
fi

# 3. Exporter les paquets pip
if command -v pip3 &>/dev/null; then
  echo "🐍 Exporting pip packages list..."
  pip3 freeze > "$backup_dir/pip_packages.txt"
  echo "✔️  pip packages list saved."
fi

# 4. Exporter les paquets npm
if command -v npm &>/dev/null; then
  echo "📦 Exporting npm global packages list..."
  npm list -g --depth=0 > "$backup_dir/npm_packages.txt"
  echo "✔️  npm packages list saved."
fi

# 5. Copier clés SSH (avec confirmation)
read -p "🔐 Do you want to backup your SSH keys? (y/N) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  mkdir -p "$backup_dir/.ssh"
  cp -r "$HOME/.ssh/"* "$backup_dir/.ssh/"
  echo "✔️  SSH keys backed up."
else
  echo "ℹ️  SSH keys backup skipped."
fi

# 6. Exporter configuration git globale
echo "🔧 Exporting global git configuration..."
git config --global --list > "$backup_dir/git_global_config.txt"
echo "✔️  Git global config saved."

# 7. Archiver le dossier de backup
archive_file="$HOME/migration_backup_$timestamp.tar.gz"
tar -czvf "$archive_file" -C "$backup_dir" .
echo "📦 Backup archive created at $archive_file"

echo "🎉 Backup completed successfully!"