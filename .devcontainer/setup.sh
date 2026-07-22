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

echo "Installing Halmos (formal verification)..."
pip install --break-system-packages halmos

echo "Installing Aderyn (static analysis)..."
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/cyfrin/aderyn/releases/latest/download/aderyn-installer.sh | bash
source "$HOME/.cargo/env" 2>/dev/null || true

echo "Installing Python 3.11 for Mythril (isolated environment)..."
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install -y python3.11 python3.11-venv python3.11-dev build-essential

echo "Setting up isolated Mythril environment..."
python3.11 -m venv "$HOME/mythril-env"
source "$HOME/mythril-env/bin/activate"
pip install mythril
deactivate

echo "Adding mythscan shortcut..."
cat >> "$HOME/.bashrc" << 'EOF'

# Mythril shortcut: passes real subcommands through, defaults to 'analyze' otherwise
mythscan() {
    source "$HOME/mythril-env/bin/activate"
    case "$1" in
        analyze|a|disassemble|d|concolic|c|foundry|f|list-detectors|read-storage|function-to-hash|hash-to-address|version|help|safe-functions)
            myth "$@"
            ;;
        *)
            myth analyze "$@"
            ;;
    esac
    deactivate
}
EOF

echo "Installing solc 0.6.12 (for testing older-pragma contracts like CAKE)..."
pip install --break-system-packages solc-select
solc-select install 0.6.12
solc-select use 0.6.12

echo "Linking solc 0.6.12 into Mythril's compiler cache (avoids network fetch)..."
mkdir -p "$HOME/.solcx"
cp "$HOME/.solc-select/artifacts/solc-0.6.12/solc-0.6.12" "$HOME/.solcx/solc-v0.6.12"
chmod +x "$HOME/.solcx/solc-v0.6.12"

echo "Installing Go (required for Medusa)..."
curl -L https://go.dev/dl/go1.23.4.linux-amd64.tar.gz -o /tmp/go.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> "$HOME/.bashrc"
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

echo "Installing Medusa (property-based fuzzer)..."
go install github.com/crytic/medusa@latest

echo "Setup complete."