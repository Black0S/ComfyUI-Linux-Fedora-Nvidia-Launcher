# ComfyUI Linux Nvidia Launcher

<div align="center">

![Fedora](https://img.shields.io/badge/Fedora-Linux-51A2DA?style=for-the-badge&logo=fedora&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.13-3776AB?style=for-the-badge&logo=python&logoColor=white)
![PyTorch](https://img.shields.io/badge/PyTorch-CUDA_13.0-EE4C2C?style=for-the-badge&logo=pytorch&logoColor=white)
![ComfyUI](https://img.shields.io/badge/ComfyUI-Latest-4B8BBE?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A streamlined launcher for running ComfyUI natively on Fedora Linux with NVIDIA GPU acceleration.**  
Automated setup, local virtual environment, and PyTorch CUDA — zero hassle.

</div>

---

## 📁 Project Structure

```
comfyui-linux-launcher/
├── comfyui/                    # ComfyUI clone target directory
├── install.sh                  # Dependency checker & full installer
├── launch.sh                   # ComfyUI launcher (uses local venv)
└── Update Scripts/
    ├── update-comfyui.sh       # Pull latest ComfyUI changes
    └── update-torch.sh         # Upgrade to latest PyTorch CUDA build
```

---

## ✅ Requirements

| Requirement | Notes |
|---|---|
| Fedora Linux | Other RPM-based distros should work |
| NVIDIA GPU | GTX 10xx series or newer recommended |
| NVIDIA Drivers | Install via [RPM Fusion](https://rpmfusion.org/) — see note below |
| CUDA Toolkit | Optional — PyTorch bundles its own CUDA runtime |
| Python 3.13 | Installed automatically via `dnf` if missing |
| git | Installed automatically via `dnf` if missing |
| Internet Connection | Required during install & update steps |

> **NVIDIA Drivers on Fedora** — If not already installed, use RPM Fusion:
> ```bash
> sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
>   https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
> sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
> ```

---

## 🚀 Quick Start

### 0. Clone or Download this Repo

```bash
git clone <this-repo-url>
cd <repo-folder>
```

### 1. Make Scripts Executable

```bash
chmod +x install.sh launch.sh "Update Scripts/update-comfyui.sh" "Update Scripts/update-torch.sh"
```

> Scripts must be executed from their own directory.

### 2. Run the Installer

Clones ComfyUI, creates a local Python 3.13 virtual environment, and installs all dependencies with CUDA support:

```bash
./install.sh
```

### 3. Launch ComfyUI

```bash
./launch.sh
```

### 4. Update ComfyUI

```bash
cd "Update Scripts"
./update-comfyui.sh
```

### 5. Update PyTorch (CUDA)

```bash
cd "Update Scripts"
./update-torch.sh
```

---

## 🌐 Access & Shutdown

**Web Interface** — Once ComfyUI is running, open your browser at: http://127.0.0.1:8188

**Startup Time** — First launch may take longer as models and GPU kernels initialize. Please be patient.

**Clean Shutdown** — Press `Ctrl+C` in the terminal running `launch.sh`. If processes remain:

```bash
pkill -f "comfyui/main.py"
```

---

## 🔧 Technical Details

### `install.sh`
- Checks for `git` and `python3.13` — installs via `dnf` if missing
- Detects NVIDIA GPU via `nvidia-smi` and reports driver + VRAM
- Clones or updates [ComfyUI](https://github.com/comfyanonymous/ComfyUI) into `./comfyui`
- Creates or reuses a local virtualenv at `./comfyui/.venv` using **Python 3.13**
- Installs **PyTorch + torchvision + torchaudio** with CUDA 13.0 (official ComfyUI recommendation):
  ```bash
  pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu130
  ```
- Installs ComfyUI's Python dependencies
- Clones or updates [ComfyUI-Manager](https://github.com/ltdrdata/ComfyUI-Manager)
- Prints a CUDA availability check at the end

### `launch.sh`
- Uses `./comfyui/.venv/bin/python` to run `comfyui/main.py`
- Passes `--cuda-device 0` to use the primary GPU
- Forwards any additional arguments (e.g. `./launch.sh --listen 0.0.0.0`)

### `Update Scripts/update-comfyui.sh`
- Fetches and rebases the latest ComfyUI commits
- Updates git submodules if present
- Reinstalls project dependencies in the local venv

### `Update Scripts/update-torch.sh`
- Verifies the `comfyui/` directory and local venv exist
- Upgrades pip
- Installs the latest stable PyTorch with CUDA 13.0
- Prints GPU info and VRAM after update

---

## 🔁 Switching CUDA Version

If your GPU requires a different CUDA version, edit the `--extra-index-url` in `install.sh` and `update-torch.sh`:

| CUDA Version | Index URL |
|---|---|
| CUDA 11.8 | `https://download.pytorch.org/whl/cu118` |
| CUDA 12.1 | `https://download.pytorch.org/whl/cu121` |
| CUDA 12.4 | `https://download.pytorch.org/whl/cu124` |
| CUDA 12.8 | `https://download.pytorch.org/whl/cu128` |
| CUDA 13.0 | `https://download.pytorch.org/whl/cu130` *(default)* |

---

## 📦 Portability

The entire `comfyui/` folder (including `.venv`) can be moved to another Linux machine with a compatible NVIDIA GPU. For maximum portability, run `./install.sh` on the new machine — it handles everything from scratch.

> **Note:** Ensure `python3.13` is available on the target machine. On Fedora: `sudo dnf install -y python3.13`

---

## 📄 License

This project is released under the [MIT License](LICENSE).

---

<div align="center">

Made with ❤️ for the Fedora + NVIDIA community

</div>