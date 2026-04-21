# StoryBooks Flutter Prototype

This prototype demonstrates a cross-platform storybook using Flutter with hooks for Rive/Lottie animations, page-turn audio, and narration (pre-generated audio or TTS fallback).

Quick start

1. Ensure Flutter is installed (stable channel).
2. Create a Flutter app and replace `lib/main.dart` and `pubspec.yaml` with the files in `flutter_prototype`, or run in-place after `flutter create`.

Commands

```bash
flutter create story_books_app
cd story_books_app
# copy files from prisam_books into this project (overwrite lib and pubspec)
flutter pub get
flutter run
```

Adding assets

- Per-story folders: assets are organized per-story under `assets/stories/<story_slug>/`.
	- Example: `assets/stories/best_day_out/` contains `story.json`, `images/`, `audio/`, and optional `lottie/` or `rive/` folders.
	- Filenames referenced in `story.json` are relative to the story folder (e.g. `images/page_0.png`, `audio/page_0.mp3`).
- Global assets: shared resources like `assets/images/background_paper.png` and `assets/audio/page_turn.mp3` remain at the global `assets/` level.

- Add narration audio files to each story's `audio/` folder when available (e.g. `assets/stories/<story>/audio/page_1.mp3`).
- Add Lottie or Rive files under the story's folder if you want per-page animations.

TTS and narration

The prototype will play a per-page audio asset if present; otherwise it falls back to `flutter_tts` to speak the page text.
For best quality, pre-generate high-quality neural TTS (Google Cloud, Azure Neural, Amazon Polly Neural) into each story's `audio/` folder and reference them in the story's `story.json`.

Next steps I can take for you

- Extract the Gemini share content into `assets/story_best_day_out.json` and add images.
- Pre-generate cloud neural TTS for every page (requires credentials/API key).
- Replace placeholders with Rive/Lottie animations and tune the page-turn animation.

Generating neural TTS audio (Google Cloud)

1. Create and activate a Python virtualenv and install the helper:

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r tools/requirements.txt
```

2. Set your Google service-account JSON path:

```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/sa.json
```

3. Generate MP3 files and update the story JSON:

```bash
python3 tools/generate_tts.py --story prisam_books/assets/stories/best_day_out/story.json \
	--out prisam_books/assets/stories/best_day_out/audio --update-story
```

The script will write `page_01.mp3`, `page_02.mp3`, ... into `assets/audio/` and set each page's `audio` field.

If you prefer not to use cloud TTS, the app will speak page text at runtime using `flutter_tts` (lower latency but device-dependent voice quality).
