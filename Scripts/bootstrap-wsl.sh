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
  #python3 \
  #python3-pip \
  #nodejs \
  #npm \
  docker.io \
  wslu

# --- Install Node.js via NVM ---
export NVM_VERSION="v0.39.7"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"
nvm install --lts
echo "✅ Installed Node.js via NVM"

# --- Add user to Docker group ---
sudo usermod -aG docker $USER

# --- Set up Starship prompt ---
curl -sS https://starship.rs/install.sh | sh -s -- -y

# --- Clone dotfiles if not already present ---
DOTFILES=~/dotfiles
if [ ! -d "$DOTFILES" ]; then
  git clone https://github.com/eirikio/dotfiles.git "$DOTFILES"
  echo "✅ Cloned dotfiles repo"
fi

# --- Copy .zshrc to home ---
cp "$DOTFILES/.zshrc" ~/.zshrc
echo "✅ Copied .zshrc to home"

# --- Create scripts folder and copy publish.sh ---
mkdir -p ~/scripts
cp "$DOTFILES/publish.sh" ~/scripts/
chmod +x ~/scripts/publish.sh
echo "✅ Copied publish.sh to ~/scripts"

# --- Add alias to .zshrc if not already present ---
if ! grep -q 'alias publish=' ~/.zshrc; then
  echo 'alias publish="$HOME/scripts/publish.sh"' >> ~/.zshrc
  echo "✅ Alias added to .zshrc"
fi

# --- Add WSL cheatsheet alias ---
if ! grep -q 'alias cheatsheet=' ~/.zshrc; then
  echo 'alias cheatsheet="wslview /mnt/c/Users/$USER/CheatSheet/index.html"' >> ~/.zshrc
  echo "✅ Alias added to .zshrc"
fi

# --- Optional: Upgrade installed tools ---
echo ""
echo "🔄 Checking for WSL package updates..."
sudo apt update && sudo apt upgrade -y
echo "✅ System packages updated"

# --- Optional: Upgrade NVM-managed Node (if needed) ---
if command -v nvm &>/dev/null; then
  nvm install --lts --reinstall-packages-from=current
  echo "✅ Node.js LTS version updated via NVM"
fi

# --- Optional: remove the repo ---
rm -rf "$DOTFILES"
echo "🧹 Removed dotfiles repo after setup"


# --- Set Zsh as default shell ---
chsh -s $(which zsh)

echo "✅ WSL Bootstrap Completed. Run: exec zsh or restart shell"
