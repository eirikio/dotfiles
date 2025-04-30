#!/bin/bash
set -e

echo "=== Running WSL Bootstrap Script ==="

# Update and upgrade packages
sudo apt update && sudo apt upgrade -y

# Install common dev tools
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
  npm

# Optional: Install Docker CLI (Docker Desktop must be installed on Windows)
sudo apt install -y docker.io
sudo usermod -aG docker $USER

# Set up Starship prompt
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Add Starship to .zshrc
if ! grep -q 'eval "$(starship init zsh)"' ~/.zshrc; then
  echo 'eval "$(starship init zsh)"' >> ~/.zshrc
fi

# Create ~/dev folder
mkdir -p ~/dev

# Clone dotfiles (example, replace with your actual repo)
git clone https://github.com/eirikio/dotfiles.git ~/dotfiles

# Set Zsh as default shell
chsh -s $(which zsh)

# Create a basic .zshrc if it doesn't exist
ZSHRC=~/.zshrc
if [ ! -f "$ZSHRC" ]; then
  touch "$ZSHRC"
fi

# Add Starship prompt if not already present
if ! grep -q 'eval "$(starship init zsh)"' "$ZSHRC"; then
  echo 'eval "$(starship init zsh)"' >> "$ZSHRC"
fi

# Add useful aliases
cat << 'EOF' >> "$ZSHRC"

# === Custom Aliases ===
alias ll='ls -alF'
alias gs='git status'
alias publish_project="$HOME/dotfiles/Scripts/publish.sh"
EOF

echo "✅ .zshrc configured"

echo "=== WSL Bootstrap Completed ==="
echo "Restart your shell or run: exec zsh"
