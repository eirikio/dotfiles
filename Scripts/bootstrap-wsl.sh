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
  figlet \
  toilet \
  jp2a \
  fzf \
  ripgrep \
  bat \
  unzip \
  wslu

yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# --- Install Node.js via NVM ---
export NVM_VERSION="v0.40.3"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash
export NVM_DIR="$HOME/.nvm"
\. "$HOME/.nvm/nvm.sh"
nvm install --lts
node -v
nvm current
npm -v
corepack enable pnpm
yes | pnpm
pnpm -v
echo "Installed Node.js via NVM"



# --- Add user to Docker group ---
#sudo usermod -aG docker $USER

# --- Set up Starship prompt ---
# curl -sS https://starship.rs/install.sh | sh -s -- -y

# --- Clone dotfiles if not already present ---
DOTFILES=~/dotfiles
if [ ! -d "$DOTFILES" ]; then
  git clone https://github.com/eirikio/dotfiles.git "$DOTFILES"
  echo "Cloned dotfiles repo"
fi

# --- Copy .zshrc to home ---
cp "$DOTFILES/.zshrc" ~/.zshrc
source ~/-zshrc
echo "Copied .zshrc to home"

cp "$DOTFILES/.gitconfig" ~/.gitconfig
echo "Copied .gitconfig to home"


git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/Pilaton/OhMyZsh-full-autoupdate.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ohmyzsh-full-autoupdate

# --- Install VS Code extensions ---
echo "Installing VS Code extensions..."
extensions=(
  "esbenp.prettier-vscode"
  "dbaeumer.vscode-eslint"
  "bradlc.vscode-tailwindcss"
  "donjayamanne.githistory"
  "github.copilot"
  "github.copilot-chat"
  "mhutchie.git-graph"
  "mikestead.dotenv"
  "ms-vscode.live-server"
  "ms-vscode.powershell"
  "mtxr.sqltools"
  "pkief.material-icon-theme"
  "prisma.prisma"
  "ritwickdey.liveserver"
  "sleistner.vscode-fileutils"
  "aaron-bond.better-comments"
  "dsznajder.es7-react-js-snippets"
  "ms-vscode-remote.remote-wsl"
  "pulkitgangwar.nextjs-snippets"
  "rvest.vs-code-prettier-eslint"
  "tonybaloney.vscode-pets"
  "aic.docify"
  # Add more if needed
)

if command -v code &> /dev/null; then
    for ext in "${extensions[@]}"; do
      code --install-extension $ext || echo "Failed to install $ext"
    done
else
    echo "VS Code not found; skipping extension installation."
fi

# --- Create scripts folder and copy publish.sh ---
mkdir -p ~/scripts/terminal-scripts/publish-to-git-from-cli/
cp "$DOTFILES/publish-to-git-from-cli.sh" ~/scripts/terminal-scripts/publish-to-git-from-cli/
chmod +x ~/scripts/terminal-scripts/publish-to-git-from-cli/publish-to-git-from-cli.sh
echo "Copied publish-to-git-from-cli.sh to ~/scripts/terminal-scripts/publish-to-git-from-cli/"

mkdir ~/code/
mkdir ~/random/

sudo mv $DOTFILES/nerdfonts/inconsolata /usr/share/fonts/

sudo apt install fontconfig
fc-cache -fv

# --- Optional: Upgrade installed tools ---
echo ""
echo "Checking for WSL package updates..."
sudo apt update && sudo apt upgrade -y
echo "System packages updated"

# --- Optional: Upgrade NVM-managed Node (if needed) ---
#if command -v nvm &>/dev/null; then
#  nvm install --lts --reinstall-packages-from=current
#  echo "Node.js LTS version updated via NVM"
#fi



# --- Optional: remove the repo ---
rm -rf "$DOTFILES"
echo "Removed dotfiles repo after setup"


# --- Set Zsh as default shell ---
chsh -s $(which zsh)

# Cleanup scheduled task
pwsh.exe schtasks /Delete /TN "BootstrapWSL" /F

echo ""
echo "WSL Bootstrap Completed!"
echo "Press Enter to start zsh now."
read
echo "Starting zsh..."
exec zsh
