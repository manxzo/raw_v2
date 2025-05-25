#!/bin/bash
set -euo pipefail

export USER_NAME="user"
export USER_HOME="/home/${USER_NAME}"

# Ensure HOME and permissions
sudo mkdir -p "${USER_HOME}"
sudo chown -R "${USER_NAME}:${USER_NAME}" "${USER_HOME}"

# Install dependencies as root if missing (venv, pip, curl)
sudo apt-get update
sudo apt-get install -y python3.11 python3.11-venv python3.11-distutils curl

# Switch to user for remaining install
sudo -u "${USER_NAME}" bash << 'EOF'
set -euo pipefail

export USER_HOME="$HOME"
export VENV_PATH="${USER_HOME}/.venv"

# Find python3.11 or fallback to python3
PYTHON_BIN="$(command -v python3.11 || command -v python3)"

# 1. Setup venv with python3.11 if not present
if ! [ -d "$VENV_PATH" ]; then
  "$PYTHON_BIN" -m venv "$VENV_PATH"
fi

source "$VENV_PATH/bin/activate"

# 2. Upgrade pip and install comfy-cli
pip install --upgrade pip
pip install comfy-cli

# 3. Install ComfyUI non-interactively
# Use yes to force "nvidia" for GPU and auto-confirm paths
yes | comfy --workspace="${USER_HOME}/comfy" install

# 4. Download KoboldCPP v1.92.1 CUDA 12.1 binary
KOBOLDCPP_DIR="${USER_HOME}/koboldcpp"
mkdir -p "$KOBOLDCPP_DIR"
curl -L "https://github.com/LostRuins/koboldcpp/releases/download/v1.92.1/koboldcpp-linux-x64-cuda1210" -o "${KOBOLDCPP_DIR}/koboldcpp"
chmod +x "${KOBOLDCPP_DIR}/koboldcpp"

# 5. Print versions and install locations
echo "Python version: $(python --version)"
echo "ComfyUI installed at: ${USER_HOME}/comfy"
echo "KoboldCPP binary at: ${KOBOLDCPP_DIR}/koboldcpp"
EOF
