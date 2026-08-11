#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
from pathlib import Path
import shutil
import subprocess
import sys


def run(command: list[str], cwd: Path | None = None) -> None:
    print("+", " ".join(command), flush=True)
    subprocess.run(command, cwd=cwd, check=True)


def find_seed_vc(skill_root: Path) -> Path:
    candidates = []
    if os.environ.get("AUDIO_COVER_MAKER_SEED_VC"):
        candidates.append(Path(os.environ["AUDIO_COVER_MAKER_SEED_VC"]).expanduser())
    candidates.extend([
        Path.home() / ".local/share/audio-cover-maker/seed-vc",
        skill_root.parent / "seed-vc",
    ])
    for candidate in candidates:
        if (candidate / "inference.py").is_file():
            return candidate
    raise SystemExit("Seed-VC not found. Run scripts/install_macos.sh --yes or set AUDIO_COVER_MAKER_SEED_VC.")


def demucs_python() -> str:
    configured = os.environ.get("AUDIO_COVER_MAKER_PYTHON")
    default = Path.home() / ".local/share/audio-cover-maker/runtime/bin/python"
    if configured:
        return configured
    if default.is_file():
        return str(default)
    return sys.executable


def stem_path(root: Path, input_file: Path, stem: str) -> Path:
    matches = list(root.glob(f"*/{input_file.stem}/{stem}.wav"))
    if len(matches) != 1:
        raise SystemExit(f"Expected one {stem} stem for {input_file}, found {len(matches)}")
    return matches[0]


def main() -> None:
    parser = argparse.ArgumentParser(description="Build an authorized voice cover")
    parser.add_argument(
        "--singer-voice-song", "--singer-voice", "--original", dest="singer_voice", type=Path, required=True,
        help="song or audio containing the target/reference singer voice",
    )
    parser.add_argument(
        "--cover-song", "--suno-style-song", "--guide", dest="guide", type=Path, required=True,
        help="song version to cover, containing source performance and accompaniment",
    )
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--vocal-gain", type=float, default=1.0)
    parser.add_argument("--instrumental-gain", type=float, default=1.0)
    args = parser.parse_args()
    for audio in (args.singer_voice, args.guide):
        if not audio.is_file():
            parser.error(f"file not found: {audio}")
    if not shutil.which("ffmpeg"):
        raise SystemExit("ffmpeg not found; run the installer first")

    output = args.output_dir.resolve()
    stems = output / "stems"
    converted_dir = output / "converted"
    output.mkdir(parents=True, exist_ok=True)
    converted_dir.mkdir(parents=True, exist_ok=True)
    python = demucs_python()

    for audio in (args.singer_voice.resolve(), args.guide.resolve()):
        run([python, "-m", "demucs", "--two-stems", "vocals", "-o", str(stems), str(audio)])
    reference_vocal = stem_path(stems, args.singer_voice, "vocals")
    guide_vocal = stem_path(stems, args.guide, "vocals")
    accompaniment = stem_path(stems, args.guide, "no_vocals")

    skill_root = Path(__file__).resolve().parent.parent
    seed_vc = find_seed_vc(skill_root)
    seed_python = seed_vc / ".venv/bin/python"
    if not seed_python.is_file():
        seed_python = Path(sys.executable)
    run([
        str(seed_python), "inference.py",
        "--source", str(guide_vocal),
        "--target", str(reference_vocal),
        "--output", str(converted_dir),
        "--diffusion-steps", "30",
        "--length-adjust", "1.0",
        "--inference-cfg-rate", "0.7",
        "--f0-condition", "true",
        "--auto-f0-adjust", "false",
        "--semi-tone-shift", "0",
        "--fp16", "false",
    ], cwd=seed_vc)
    converted = max(converted_dir.glob("*.wav"), key=lambda path: path.stat().st_mtime)
    final = output / "final-cover.wav"
    run([
        "ffmpeg", "-y", "-i", str(converted), "-i", str(accompaniment),
        "-filter_complex",
        f"[0:a]volume={args.vocal_gain}[v];[1:a]volume={args.instrumental_gain}[i];[v][i]amix=inputs=2:duration=longest:normalize=0,alimiter=limit=0.95[out]",
        "-map", "[out]", "-c:a", "pcm_s24le", str(final),
    ])
    print(final)


if __name__ == "__main__":
    main()
