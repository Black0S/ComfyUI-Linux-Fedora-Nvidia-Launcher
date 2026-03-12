#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="comfyui"
REPO_URL="https://github.com/comfyanonymous/ComfyUI.git"
VENV_DIR="$REPO_DIR/.venv"

echo "==> Checking system dependencies"
MISSING_PKGS=()
command -v git >/dev/null 2>&1 || MISSING_PKGS+=(git)
if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
  echo "Installing missing packages: ${MISSING_PKGS[*]}"
  sudo dnf install -y "${MISSING_PKGS[@]}"
fi

echo "==> Checking Python 3.13"
if ! command -v python3.13 >/dev/null 2>&1; then
  echo "python3.13 not found. Installing via dnf..."
  sudo dnf install -y python3.13
fi
echo "✅ $(python3.13 --version)"

echo "==> Checking NVIDIA GPU & CUDA"
if ! command -v nvidia-smi >/dev/null 2>&1; then
  echo "⚠️  Warning: nvidia-smi not found. Make sure your NVIDIA drivers are installed."
  echo "   Visit https://www.nvidia.com/Download/index.aspx or use your distro's package manager."
  echo "   Continuing anyway..."
else
  echo "✅ NVIDIA GPU detected:"
  nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
fi

echo "==> Checking CUDA toolkit"
if ! command -v nvcc >/dev/null 2>&1; then
  echo "⚠️  Warning: nvcc not found. CUDA toolkit may not be installed."
  echo "   PyTorch will still work if CUDA runtime is available."
else
  echo "✅ CUDA version: $(nvcc --version | grep release | awk '{print $6}' | tr -d ',')"
fi

echo "==> Clone / update of ComfyUI repo in ./$REPO_DIR"
if [ -d "$REPO_DIR/.git" ]; then
  echo "The repo already exists. Getting latest changes..."
  git -C "$REPO_DIR" pull --rebase
else
  git clone "$REPO_URL" "$REPO_DIR"
fi

echo "==> Installing ComfyUI-Manager in $REPO_DIR/custom_nodes"
CUSTOM_NODES_DIR="$REPO_DIR/custom_nodes"
MANAGER_DIR="$CUSTOM_NODES_DIR/comfyui-manager"
mkdir -p "$CUSTOM_NODES_DIR"
if [ -d "$MANAGER_DIR/.git" ]; then
  echo "ComfyUI-Manager already exists, updating..."
  git -C "$MANAGER_DIR" pull --rebase
else
  git clone https://github.com/ltdrdata/ComfyUI-Manager "$MANAGER_DIR"
fi

echo "==> Creating / reusing a virtualenv in $VENV_DIR"
if [ -d "$VENV_DIR" ]; then
  echo "Existing virtualenv found, reusing it."
else
  python3.13 -m venv "$VENV_DIR"
fi

VENV_PY="$VENV_DIR/bin/python"

echo "==> Updating pip in the virtualenv"
"$VENV_PY" -m pip install --upgrade pip setuptools wheel

echo "==> Installing PyTorch with CUDA support (cu130)"
"$VENV_PY" -m pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu130

echo "==> Installing ComfyUI dependencies in the virtualenv"
"$VENV_PY" -m pip install -r "$REPO_DIR/requirements.txt"

echo ""
echo "✅ Installation complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 PyTorch + CUDA check:"
"$VENV_PY" -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'GPU: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"N/A\"}')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "To launch: ./launch.sh"