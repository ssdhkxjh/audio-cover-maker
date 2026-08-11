---
name: audio-cover-maker
description: Create authorized AI song covers locally on Apple Silicon Macs from a target singer reference song and the song version to cover. Use when a user wants to separate vocals and accompaniment with Demucs, convert singing voice with Seed-VC, and mix converted vocals with the cover song instrumental.
---

# Audio Cover Maker

Create voice covers only from audio and voices the user owns or has permission to use. Never present generated audio as an authentic performance by the reference singer.

## Workflow

1. Detect the language used by the user and reply in the same language. If the first message contains only the skill name or the language is unclear, ask exactly one short question before doing anything else: “Which language would you like me to communicate with you in?” Make clear this means the conversation language, not the song language. Do not assume English from the skill name. Do not rely on an inferred cross-task preference because it may be unavailable or stale.
2. Once the conversation language is known, run `scripts/doctor.sh` immediately.
3. If dependencies are missing, explain what will be installed and ask for installation approval. While waiting, tell the user they can prepare `singer-voice-song`.
4. When the environment is ready, ask only for the first local path:

   > Please provide the local path of `singer-voice-song.mp3`: a song containing the singer's vocal timbre you want in the final result. Background music is fine because Demucs will extract the vocal. Other common audio formats also work.

5. After receiving and validating the first path, ask only for the second local path:

   > Please provide the local path of `cover-song.mp3`: the song version you want to cover. You may optionally use [Suno](https://suno.com/) first to change it into a style that better suits the target singer. Other common audio formats also work.

   This request must always include the Suno explanation and link above, translated into the conversation language. Never shorten it to only “the song version you want to cover.”

6. Suno is optional. If the user wants to change the cover song's style, explain in one sentence that [Suno](https://suno.com/) can create a version better suited to the target singer, then wait for the chosen song's local path. Do not transcribe lyrics or generate Suno prompts.
7. After both files are available, run `scripts/run_pipeline.py --singer-voice-song SINGER_SONG --cover-song COVER_SONG --output-dir OUTPUT`.
8. Return the final file and mention any warnings printed by the pipeline.

After any tool call, repeat only the current missing-path request in the final visible response. Say “provide/send the local path,” never “upload/attach the file.” Commentary may be collapsed, so never rely on commentary alone for required user instructions.

## Conversation style

- Keep every user-facing message to one or two short sentences.
- Ask only one question at a time.
- Avoid technical details unless the user asks or must approve an installation.
- Provide brief progress updates during long-running audio processing.

## Audio roles

- Singer voice sample: target/reference timbre for Seed-VC.
- Cover-song vocal: source performance carrying lyrics, melody, rhythm, and expression.
- Cover-song accompaniment: instrumental used in the final mix.

## Dependency behavior

- Support macOS on Apple Silicon in the first release.
- Never hardcode a user's path.
- Resolve Seed-VC from `AUDIO_COVER_MAKER_SEED_VC`, then `~/.local/share/audio-cover-maker/seed-vc`, then a sibling `seed-vc` directory.
- Treat downloads, Homebrew installs, repository clones, and Python package installs as state-changing operations. Explain and obtain confirmation first.
- Read [references/troubleshooting.md](references/troubleshooting.md) only when installation or audio processing fails.

## Quality checks

- Prefer WAV inputs and output.
- Prefer a singer reference with clear vocals and little reverb; Demucs extracts its vocal before Seed-VC.
- Warn when the reference vocal contains heavy reverb or accompaniment leakage.
- Keep intermediate stems so the user can inspect them.
- Do not silently time-stretch or pitch-shift. Explain the mismatch when the generated arrangement differs substantially from the source.
