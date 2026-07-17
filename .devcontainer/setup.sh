#!/usr/bin/env bash
set -euo pipefail

echo "Installing Python and pip..."
sudo apt-get update
sudo apt-get install -y python3 python3-pip

echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "Installing Foundry..."
curl -L https://foundry.paradigm.xyz | bash
export PATH="$HOME/.foundry/bin:$PATH"
~/.foundry/bin/foundryup

echo "Installing Slither (static analysis)..."
pip install --break-system-packages slither-analyzer

echo "Setup complete."
