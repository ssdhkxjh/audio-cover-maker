# audio-cover-maker

A local, open-source workflow for making authorized AI voice covers on Apple Silicon Macs.

It separates stems with Demucs, converts the cover-song vocal with Seed-VC, and mixes the result with the cover-song accompaniment.

Prepare two files before starting:

1. `singer-voice-song.mp3`: a song containing the voice wanted in the result. Background music is fine; Demucs extracts the vocal first.
2. `cover-song.mp3`: the song version you want to cover. Optionally use [Suno](https://suno.com/) first to change it into a style better suited to the target singer.

Suno is optional. Prepare prompts and lyrics yourself with any tool you prefer; this project does not generate or transcribe them.

## Install

Install the skill globally for both Claude Code and Codex with the [Skills CLI](https://github.com/vercel-labs/skills):

```bash
npx skills add https://github.com/ssdhkxjh/audio-cover-maker \
  --global \
  --agent claude-code \
  --agent codex \
  --yes
```

This installs the skill instructions and scripts. The audio-processing dependencies are installed separately on first setup.

Alternatively, clone this repository and ask your AI coding assistant to use `SKILL.md` directly.

Check dependencies:

```bash
./scripts/doctor.sh
```

After reviewing what will be changed, install on an Apple Silicon Mac:

```bash
./scripts/install_macos.sh --yes
```

## Run

```bash
./scripts/run_pipeline.py \
  --singer-voice-song /path/to/singer-voice-song.mp3 \
  --cover-song /path/to/cover-song.mp3 \
  --output-dir ./output
```

Only use audio and voices you own or have permission to use. Clearly label generated results and do not impersonate a real performer.

Users are solely responsible for obtaining all necessary permissions to use the audio and voices. This repository and its contributors assume no liability for any resulting legal claims or consequences.
