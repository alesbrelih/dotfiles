#!/bin/bash

# setup_kali.sh
# Improved setup script for Kali Linux (x86_64 or ARM64)

set -e

echo "[-] Starting setup..."

# 1. Detect Architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) NVIM_ARCH="linux-x86_64" ;;
    aarch64|arm64) NVIM_ARCH="linux-arm64" ;;
    *) echo "[!] Unsupported architecture: $ARCH"; exit 1 ;;
esac
echo "[-] Detected architecture: $ARCH"

# 2. Update and Install Core Tools
echo "[-] Updating package lists..."
sudo apt-get update
echo "[-] Installing tmux, stow, alacritty, curl, git, and build dependencies..."
sudo apt-get install -y tmux stow alacritty curl git tar build-essential spice-vdagent qemu-guest-agent

# 3. Install Latest Neovim
echo "[-] Installing latest Neovim for $ARCH..."

# Remove existing apt version to avoid confusion
sudo apt-get remove -y neovim neovim-runtime || true

# Neovim provides arm64 binaries in recent releases (0.10+)
NVIM_RELEASE_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-${NVIM_ARCH}.tar.gz"
TEMP_DIR=$(mktemp -d)

echo "[-] Downloading Neovim from $NVIM_RELEASE_URL..."
if curl -L --fail "$NVIM_RELEASE_URL" -o "$TEMP_DIR/nvim.tar.gz"; then
    echo "[-] Extracting to /opt/nvim..."
    sudo rm -rf /opt/nvim
    sudo mkdir -p /opt/nvim
    sudo tar -C /opt/nvim --strip-components=1 -xzf "$TEMP_DIR/nvim.tar.gz"
    
    echo "[-] Linking nvim to /usr/local/bin/nvim..."
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
else
    echo "[!] Failed to download pre-built binary. Neovim might not have a release for $NVIM_ARCH yet."
    echo "[!] Attempting to install via apt as fallback..."
    sudo apt-get install -y neovim
fi

rm -rf "$TEMP_DIR"

# 4. Setup Tmux Plugin Manager (TPM)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "[-] Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# 5. Stow Configurations
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$DOTFILES_DIR"

echo "[-] Applying dotfiles from $DOTFILES_DIR..."

# Define which packages to stow
PACKAGES=("tmux")

for pkg in "${PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        echo "[-] Stowing $pkg..."
        # -v: verbose, -t: target directory (Home), -R: restow
        stow -v -t "$HOME" -R "$pkg"
    else
        echo "[!] Skipping $pkg: directory not found."
    fi
done

echo "[-] Setup complete! You may need to restart your shell."
