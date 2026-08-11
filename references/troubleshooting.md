# Troubleshooting

## Seed-VC is not found

Set `AUDIO_COVER_MAKER_SEED_VC` to a Seed-VC checkout containing `inference.py`, or run the installer.

## Demucs is not found

The default installer puts Demucs in `~/.local/share/audio-cover-maker/runtime`. Set `AUDIO_COVER_MAKER_PYTHON` to another Python executable when using an existing environment.

## Metallic or doubled vocals

Inspect the separated vocal stems. Reverb and accompaniment leakage usually become more obvious after conversion. Try a cleaner reference excerpt or a different Demucs model.

## Timing mismatch

Use a Suno generation with the same lyric structure as the original. This release does not silently warp an arrangement to fit another arrangement.

## First run is slow

Demucs and Seed-VC download model weights on first use. The downloads are free but can use several gigabytes of disk space.
