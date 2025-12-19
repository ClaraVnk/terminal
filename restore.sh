#!/usr/bin/env bash

set -e

# Vérifie qu'un argument est passé (le fichier archive)
if [ -z "$1" ]; then
  echo "⚠️ Usage: $0 path_to_backup_archive.tar.gz"
  exit 1
fi

backup_archive="$1"
restore_dir="$HOME/migration_restore_$(date +%Y%m%d_%H%M%S)"

# 1. Décompresser l'archive dans le dossier de restauration
mkdir -p "$restore_dir"
echo "📂 Extracting archive $backup_archive to $restore_dir..."
tar -xzvf "$backup_archive" -C "$restore_dir"
echo "✔️ Archive extracted."

# 2. Restaurer les dotfiles
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

# 3. Installer les paquets Homebrew
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

# 4. Installer les paquets pip
if command -v pip3 &>/dev/null; then
  if [ -f "$restore_dir/pip_packages.txt" ]; then
    echo "🐍 Installing pip packages..."
    pip3 install -r "$restore_dir/pip_packages.txt"
    echo "✔️ pip packages installed."
  fi
fi

# 5. Installer les paquets npm
if command -v npm &>/dev/null; then
  if [ -f "$restore_dir/npm_packages.txt" ]; then
    echo "📦 Installing npm global packages..."
    tail -n +2 "$restore_dir/npm_packages.txt" | awk '{print $2}' | cut -d@ -f1 | xargs npm install -g
    echo "✔️ npm packages installed."
  fi
fi

# 6. Restaurer les clés SSH (avec confirmation)
read -p "🔐 Restore your SSH keys? (y/N) " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  if [ -d "$restore_dir/.ssh" ]; then
    cp -r "$restore_dir/.ssh" "$HOME/"
    echo "✔️ SSH keys restored."
  else
    echo "⚠️ No SSH keys found in backup."
  fi
else
  echo "ℹ️ SSH keys restoration skipped."
fi

# 7. Restaurer la config git globale
if [ -f "$restore_dir/git_global_config.txt" ]; then
  echo "🔧 Restoring git global config..."
  while IFS='=' read -r key value; do
    # Skip empty lines and comments
    [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
    # Trim whitespace from key and value
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)
    # Set git config with proper quoting
    git config --global "$key" "$value"
  done < "$restore_dir/git_global_config.txt"
  echo "✔️ Git global config restored."
fi

echo "🎉 Restore completed. Please restart your terminal session."