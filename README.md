# 🌟 LearnGeeta - Gamified Bhagavad Gita Learning App

[![Flutter](https://flutter.dev/images/flutter-logo-sharing.png)](https://flutter.dev) [![Supabase](https://supabase.com/images/logomark-gradient.svg)](https://supabase.com)

**LearnGeeta** is an engaging mobile app that makes learning the sacred **Bhagavad Gita** fun and interactive through gamified experiences. Earn XP, level up, unlock games, and deepen your understanding of Lord Krishna's teachings while tracking your spiritual progress!

## 🚀 Features

- **📖 Gita Reader**: Read verses with English transliteration & translation + **Text-to-Speech** audio playback
- **🎮 11+ Mini-Games**:
  | Game | Description |
  |------|-------------|
  | Missing Word Mantra | Fill missing words in mantras |
  | Battlefield Debate | Krishna-Arjuna debate challenges |
  | Krishna Says | Simon Says-style memory game |
  | Chapter Quest | Chapter-based trivia quests |
  | Shloka Match | Pair shloka lines |
  | Verse Order | Arrange verses in correct sequence |
  | True/False | Gita knowledge quick-fire |
  | Dharma Choices | Ethical decision-making scenarios |
  | Karma Path | Choose-your-path karma simulation |
  | Shloka Speedrun | Timed shloka recitation |
  | Wheel of Gunas | Sattva/Rajas/Tamas spinner game |
- **📊 Progress Tracking**: XP system, levels, game stats, achievements
- **👤 User Profiles**: Personalized progress sync
- **🔒 Secure Auth**: Supabase-powered login/signup/password reset
- **🎨 Beautiful UI**: Custom saffron-themed gradients, animations (confetti), Google Fonts
- **⚡ Offline-First**: Local Gita JSON data + cloud sync

## 🛠️ Tech Stack

| Category | Technologies |
|----------|--------------|
| **Framework** | Flutter (Dart 3.10+) |
| **Backend** | Supabase (Auth, Database, Realtime) |
| **State Management** | Provider (ChangeNotifier) |
| **Architecture** | Repository Pattern + Dependency Injection |
| **Local Storage** | SharedPreferences |
| **Audio** | flutter_tts |
| **Animations** | confetti |
| **Fonts/Assets** | Google Fonts, bhagavad_gita.json |
| **Other** | flutter_dotenv, http |

## 🏗️ System Architecture

```
┌─────────────────┐    ┌──────────────────┐
│     Flutter     │◄──►│    Supabase      │
│     UI Layer    │    │ (Auth/DB/Storage)│
└─────────┬───────┘    └──────────────────┘
          │
┌─────────┼─────────┐
│ Providers/ │       │ Core (Theme/ │
│Controllers │       │ Widgets/ │
└─────────┼─────────┘ │Models) │
          │           │
┌─────────┼─────────┐ │
│ Repository Layer  │◄┼─── Local JSON
│ (Auth/Profile/    │ │  (Gita Data)
│  Progress/Game)   │
└───────────────────┘
```

- **Entry**: `main.dart` → `AuthGate` → `BottomNav` (Home/Learn/Play/Progress)
- **Data Flow**: Controllers fetch from Repositories → Supabase/Local JSON
- **Navigation**: Direct `MaterialPageRoute` for games, `IndexedStack` for tabs


## 🚀 Quick Start

### Prerequisites
- Flutter SDK >=3.10.4
- Supabase Account (free tier works)

### Setup
1. Clone/Download the repo
2. Create `.env` from `.env.example` (or copy existing):
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_anon_key
   ```
3. Get Supabase keys from [supabase.com](https://supabase.com)
4. Install dependencies:
   ```bash
   flutter pub get
   ```
5. Run the app:
   ```bash
   flutter run
   ```

### Android/iOS Builds
```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS (macOS required)
```

## 🎮 How to Play
1. **Sign Up/Login** with email
2. **Learn**: Read Gita chapters with audio
3. **Play**: Unlock games by leveling up (higher level = more games)
4. **Track**: Monitor XP, stats in Progress tab
5. **Level Up**: Complete games to earn XP!

## 🤝 Contributing
1. Fork the repo
2. Create feature branch (`git checkout -b feature/new-game`)
3. Add your game in `lib/features/games/`
4. Update `GameDefinition` in PlayController
5. Submit PR!

## 📄 License
MIT License - Feel free to use/modify!

## 🙏 Acknowledgments
- [Bhagavad Gita JSON Dataset](assets/data/bhagavad_gita.json)
- Built with ❤️ for spiritual growth

---

⭐ **Star the repo if you find it useful!** 🙌
