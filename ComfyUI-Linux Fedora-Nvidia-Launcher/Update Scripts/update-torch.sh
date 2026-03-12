#!/usr/bin/env bash
set -e

# Torch update script (CUDA / Nvidia version)
# Retrieves and installs the latest stable PyTorch with CUDA support

# Check that the comfyui directory exists
if [ ! -d "../comfyui" ]; then
    echo "❌ Error: the directory '../comfyui' does not exist."
    echo "Make sure you have run '../install.sh' first."
    exit 1
fi

# Check that the venv exists
if [ ! -d "../comfyui/.venv" ]; then
    echo "❌ Error: the virtual environment '../comfyui/.venv' does not exist."
    echo "Make sure you have run '../install.sh' first."
    exit 1
fi

echo "🔄 Updating Torch (CUDA 13.0 / stable version)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "📦 Activating venv and updating pip..."
source ../comfyui/.venv/bin/activate
pip install --upgrade pip

echo "📥 Installing PyTorch, torchvision, torchaudio (stable, CUDA 13.0)..."
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu130

echo ""
echo "✅ Update complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Installed versions:"
python -c "
import torch
print(f'PyTorch:        {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'CUDA version:   {torch.version.cuda}')
    print(f'GPU:            {torch.cuda.get_device_name(0)}')
    print(f'VRAM:           {torch.cuda.get_device_properties(0).total_memory // 1024**2} MB')
"