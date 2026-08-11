#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" != "--yes" ]]; then
  echo "This installs Homebrew packages, clones Seed-VC, and creates Python environments."
  echo "Re-run with --yes only after the user confirms."
  exit 2
fi
if [[ "$(uname -s)" != "Darwin" || "$(uname -m)" != "arm64" ]]; then
  echo "This release supports only macOS Apple Silicon." >&2
  exit 1
fi
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Install it from https://brew.sh and run this again." >&2
  exit 1
fi

missing_brew_packages=()
command -v ffmpeg >/dev/null 2>&1 || missing_brew_packages+=(ffmpeg)
command -v git >/dev/null 2>&1 || missing_brew_packages+=(git)
command -v python3 >/dev/null 2>&1 || missing_brew_packages+=(python@3.10)
if (( ${#missing_brew_packages[@]} )); then
  brew install "${missing_brew_packages[@]}"
fi
install_root="${AUDIO_COVER_MAKER_HOME:-$HOME/.local/share/audio-cover-maker}"
mkdir -p "$install_root"
python_bin="$(command -v python3)"

if [[ ! -d "$install_root/runtime" ]]; then
  "$python_bin" -m venv "$install_root/runtime"
fi
"$install_root/runtime/bin/python" -m pip install --upgrade pip
"$install_root/runtime/bin/python" -m pip install demucs

seed_vc_path="${AUDIO_COVER_MAKER_SEED_VC:-}"
if [[ -z "$seed_vc_path" ]]; then
  script_dir="$(cd "$(dirname "$0")" && pwd)"
  sibling_seed_vc="$(cd "$script_dir/../.." && pwd)/seed-vc"
  if [[ -f "$sibling_seed_vc/inference.py" ]]; then
    seed_vc_path="$sibling_seed_vc"
  else
    seed_vc_path="$install_root/seed-vc"
  fi
fi
if [[ ! -d "$seed_vc_path/.git" ]]; then
  git clone https://github.com/Plachtaa/seed-vc.git "$seed_vc_path"
fi
seed_vc_venv_created=false
if [[ ! -d "$seed_vc_path/.venv" ]]; then
  "$python_bin" -m venv "$seed_vc_path/.venv"
  seed_vc_venv_created=true
fi
if [[ "$seed_vc_venv_created" == true ]]; then
  "$seed_vc_path/.venv/bin/python" -m pip install --upgrade pip
  "$seed_vc_path/.venv/bin/python" -m pip install -r "$seed_vc_path/requirements-mac.txt"
fi

echo "Installed. Add this to your shell profile if using a custom location:"
echo "export AUDIO_COVER_MAKER_SEED_VC=\"$seed_vc_path\""
