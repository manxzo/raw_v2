#!/bin/bash

set -euo pipefail

export USER_NAME="user"
export USER_HOME="/home/${USER_NAME}"

# Ensure HOME and permissions
sudo mkdir -p "${USER_HOME}"
sudo chown -R "${USER_NAME}:${USER_NAME}" "${USER_HOME}"

# Switch to user for all install steps
sudo -u "${USER_NAME}" bash << 'EOF'
set -euo pipefail

export USER_HOME="$HOME"
export VENV_PATH="${USER_HOME}/.venv"

# 1. Setup venv with python3.11 if not present
if ! [ -d "$VENV_PATH" ]; then
  python3 -m venv "$VENV_PATH"
fi

source "$VENV_PATH/bin/activate"

# 2. Upgrade pip and install comfy-cli
pip install --upgrade pip
pip install comfy-cli

# 3. Install ComfyUI using comfy-cli to $USER_HOME/comfy
comfy --install-completion
comfy --workspace="${USER_HOME}/comfy" install 

# 4. Download KoboldCPP v1.92.1 CUDA 12.1 binary
KOBOLDCPP_DIR="${USER_HOME}/koboldcpp"
mkdir -p "$KOBOLDCPP_DIR"
curl -L "https://github.com/LostRuins/koboldcpp/releases/download/v1.92.1/koboldcpp-linux-x64-cuda1210" -o "${KOBOLDCPP_DIR}/koboldcpp"
chmod +x "${KOBOLDCPP_DIR}/koboldcpp"

# 5. Print versions and where things are
echo "Python version: $(python --version)"
echo "ComfyUI installed at: ${USER_HOME}/comfy"
echo "KoboldCPP binary at: ${KOBOLDCPP_DIR}/koboldcpp"

EOF
