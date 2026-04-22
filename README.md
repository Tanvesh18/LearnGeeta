# LearnGeeta

LearnGeeta is a Flutter app that helps people study the Bhagavad Gita through reading, audio support, and short game-based practice.

## What is in the app

- Email/password auth with Supabase
- Reader flow for chapters and verses
- Sanskrit text with transliteration, translation, and word-level support
- Text-to-speech playback for verses
- Gamified practice modes under Play
- XP, levels, streaks, and achievement tracking

## Main game modes

- Shloka Match
- Verse Order
- True or False
- Dharma Choices
- Missing Word Mantra
- Chapter Quest
- Wheel of Gunas
- Krishna Memory Cards
- Battlefield Debate
- Krishna Says
- Shloka Speed Run
- Karma Path

## Tech stack

- Flutter
- Supabase (`supabase_flutter`)
- `flutter_tts`
- `shared_preferences`
- `google_fonts`

## Quick start

1. Install Flutter.
2. Add a `.env` file in the project root:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the app:

```bash
flutter run
```

## Build APK

```bash
flutter build apk --release
```

Release artifact:

- `build/app/outputs/flutter-apk/app-release.apk`

## Project layout

```text
lib/
  auth/
  core/
  features/
  navigation/
  main.dart
assets/data/
  bhagavad_gita.json
report/references/
  LEARNGEETA_REFERENCES.md
```
