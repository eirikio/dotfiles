#!/bin/bash
set -e

echo "=== Running WSL Bootstrap Script ==="

# --- Update and install packages ---
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
  git \
  curl \
  wget \
  build-essential \
  zsh \
  fzf \
  ripgrep \
  bat \
  neovim \
  unzip \
  python3 \
  python3-pip \
  nodejs \
  npm \
  docker.io

# --- Add user to Docker group ---
sudo usermod -aG docker $USER

# --- Set up Starship prompt ---
curl -sS https://starship.rs/install.sh | sh -s -- -y

# --- Clone dotfiles repo if not already present ---
DOTFILES=~/dotfiles
if [ ! -d "$DOTFILES" ]; then
  git clone https://github.com/eirikio/dotfiles.git "$DOTFILES"
  echo "✅ Cloned dotfiles repo"
fi

# --- Link .zshrc from dotfiles ---
ZSHRC="$HOME/.zshrc"
if [ -f "$DOTFILES/.zshrc" ]; then
  rm -f "$ZSHRC"
  ln -s "$DOTFILES/.zshrc" "$ZSHRC"
  echo "✅ Linked .zshrc from dotfiles"
fi

# --- Create scripts folder and copy publish.sh ---
mkdir -p ~/scripts
if [ -f "$DOTFILES/publish.sh" ]; then
  cp "$DOTFILES/publish.sh" ~/scripts/
  chmod +x ~/scripts/publish.sh
  echo "✅ Copied publish.sh to ~/scripts"
fi

# --- Add alias if not already present ---
if ! grep -q 'alias publish_project=' "$ZSHRC"; then
  echo 'alias publish_project="$HOME/scripts/publish.sh"' >> "$ZSHRC"
  echo "✅ Alias added to .zshrc"
fi

# --- Set Zsh as default shell ---
chsh -s $(which zsh)

echo "✅ WSL Bootstrap Completed. Run: exec zsh or restart shell"
