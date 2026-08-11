#!/usr/bin/env bash
set -u

fail=0
if [[ "$(uname -s)" != "Darwin" || "$(uname -m)" != "arm64" ]]; then
  echo "[missing] macOS Apple Silicon is required by this release"
  fail=1
else
  echo "[ok] macOS Apple Silicon"
fi

for command_name in git python3 ffmpeg; do
  if command -v "$command_name" >/dev/null 2>&1; then
    echo "[ok] $command_name"
  else
    echo "[missing] $command_name"
    fail=1
  fi
done

runtime_python="${AUDIO_COVER_MAKER_PYTHON:-$HOME/.local/share/audio-cover-maker/runtime/bin/python}"
if [[ -x "$runtime_python" ]] && "$runtime_python" -m demucs --help >/dev/null 2>&1; then
  echo "[ok] demucs: $runtime_python"
elif command -v demucs >/dev/null 2>&1 || python3 -m demucs --help >/dev/null 2>&1; then
  echo "[ok] demucs"
else
  echo "[missing] demucs"
  fail=1
fi

seed_vc_path="${AUDIO_COVER_MAKER_SEED_VC:-}"
if [[ -z "$seed_vc_path" ]]; then
  seed_vc_path="$HOME/.local/share/audio-cover-maker/seed-vc"
fi
if [[ ! -f "$seed_vc_path/inference.py" ]]; then
  script_dir="$(cd "$(dirname "$0")" && pwd)"
  sibling_seed_vc="$(cd "$script_dir/../.." && pwd)/seed-vc"
  if [[ -f "$sibling_seed_vc/inference.py" ]]; then
    seed_vc_path="$sibling_seed_vc"
  fi
fi
if [[ -f "$seed_vc_path/inference.py" ]]; then
  echo "[ok] Seed-VC: $seed_vc_path"
else
  echo "[missing] Seed-VC (set AUDIO_COVER_MAKER_SEED_VC or run installer)"
  fail=1
fi

exit "$fail"
