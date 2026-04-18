# Learn Geeta: An Interactive Bhagavad Gita Learning App

## Introduction

Learn Geeta is a comprehensive and engaging Flutter application designed to make the ancient wisdom of the Bhagavad Gita accessible to a modern audience. Through a unique blend of interactive games, personalized progress tracking, and a user-friendly interface, this app transforms the process of learning sacred scriptures into a fun and enriching experience.

## Project Overview

This project is a feature-rich mobile application built with Flutter and backed by Supabase. It provides a gamified environment where users can learn, understand, and memorize the shlokas (verses) and teachings of the Bhagavad Gita. The app is designed for a global audience with multilingual support and caters to various learning styles through its diverse set of games.

## Problem Statement

The Bhagavad Gita, a revered Hindu scripture, contains profound philosophical insights. However, its depth, language, and cultural context can be intimidating for new learners. Traditional methods of study often lack the engagement needed to maintain motivation, especially for younger audiences or those with busy lifestyles. There is a need for a modern, interactive platform that can break down complex concepts into digestible, memorable, and enjoyable lessons.

## Objectives

- To create an engaging and interactive platform for learning the Bhagavad Gita.
- To use gamification to motivate users and enhance learning retention.
- To provide a structured learning path with clear progression.
- To track user progress and provide a sense of accomplishment.
- To make the teachings of the Gita accessible to a wider, non-technical audience.
- To build a high-quality, production-ready application with a scalable architecture.

## Features

### Core Features
- **User Authentication**: Secure email/password signup and login.
- **Password Reset**: Functionality to reset passwords via email.
- **Home Dashboard**: Displays a "Shloka of the Day," user statistics (Level, XP, Streak), and a personalized greeting.
- **Profile Management**: Users can view their profile and manage settings like language preference.
- **Gamified Learning**: Seven unique games designed to teach different aspects of the Gita.
- **Progress Tracking**: A dedicated screen to visualize learning progress (in development).
- **Learn Module**: A section for structured lessons and content (in development).

### Game Modes
1.  **Shloka Match**: Match Sanskrit shlokas with their English translations.
2.  **Verse Order**: Arrange jumbled lines to reconstruct a complete shloka.
3.  **True or False**: Test knowledge of Gita concepts with true/false questions.
4.  **Dharma Choices**: Navigate ethical dilemmas based on Dharmic principles.
5.  **Krishna Says**: Answer multiple-choice questions based on Krishna's teachings.
6.  **Shloka Speed Run**: A timed challenge to answer as many questions as possible.
7.  **Karma Path**: An interactive story where choices affect the user's karma score.

## Technology Stack

- **Frontend**: Flutter (Cross-platform UI)
- **Backend & Database**: Supabase (PostgreSQL, Authentication)
- **State Management**: `StreamBuilder` for auth state, `SharedPreferences` for local game state.
- **UI/UX**: Material Design 3, Google Fonts, Confetti for animations.
- **Utilities**:
    - `flutter_tts`: Text-to-speech for shloka pronunciation.
    - `flutter_dotenv`: For managing environment variables.
    - `cupertino_icons`: For iOS-style icons.

## Project Architecture

The app follows a modular feature-based architecture, which keeps the concerns separated and makes the codebase scalable and maintainable.

- **`lib/`**: The root folder for all Dart code.
- **`main.dart`**: The entry point of the application. It initializes Supabase and sets up the initial routing.
- **`auth/`**: Contains all authentication-related logic and UI, including login, signup, and the `AuthGate` which directs users based on their authentication state.
- **`core/`**: Shared code, including app-wide constants (like colors) and theme definitions.
- **`features/`**: Each core feature of the app (home, learn, play, profile, progress, games) is a separate module inside this directory.
- **`navigation/`**: Contains the main navigation setup, like the bottom navigation bar.
- **`models/`**: Each game feature contains its own models for game state and content.

## Methodology

### Workflow & Internal Mechanics

1.  **Initialization**: The app starts with `main.dart`, which initializes the Supabase client using credentials from the `.env` file.
2.  **Authentication Flow**:
    - The `AuthGate` widget listens to Supabase's authentication state stream.
    - If a user is logged in, it shows the main `BottomNav` screen.
    - If no user is logged in, it shows the `LoginScreen`.
    - The `AuthService` class encapsulates all interactions with Supabase Auth (e.g., `signInWithPassword`, `signUp`, `signOut`).
3.  **Home Screen**:
    - The `HomeScreen` fetches user profile data from the `profiles` table in Supabase.
    - It calculates the "Shloka of the Day" deterministically based on the current date, ensuring every user sees the same shloka on the same day.
4.  **Game Mechanics**:
    - The `PlayScreen` acts as a hub for all games.
    - Each game in the `features/games/` directory is self-contained with its own UI, game logic, and data models.
    - Game state (like current level, score, and streak) is persisted locally on the device using the `shared_preferences` package. This allows users to pick up where they left off.
    - Questions and content for the games are currently hardcoded within their respective model files.
5.  **Data Flow**:
    - **User Data**: Stored and managed in Supabase. The `ProfileService` handles fetching and updating user profile information.
    - **Game Data**: Stored locally to ensure offline playability and quick access.
6.  **State Management**:
    - App-level state (like auth status) is managed reactively using streams from Supabase.
    - Feature-level state (like game progress) is managed locally within each feature's widgets, often using `StatefulWidget` and `setState`, with data persisted via `SharedPreferences`.

## Installation and Setup Instructions

1.  **Prerequisites**:
    - Flutter SDK (version 3.10.7 or higher)
    - A code editor like VS Code or Android Studio.
    - A Supabase account.

2.  **Clone the Repository**:
    ```bash
    git clone https://github.com/your-username/learn-geeta.git
    cd learn-geeta
    ```

3.  **Set up Supabase**:
    - Create a new project on [Supabase](https://supabase.com/).
    - In the SQL Editor, run the schema for `profiles` and `progress` tables (you would need to provide the SQL for this).
    - Go to `Project Settings` > `API` and find your Project URL and anon key.

4.  **Configure Environment Variables**:
    - Create a `.env` file in the root of the project.
    - Add your Supabase credentials to the `.env` file:
      ```
      SUPABASE_URL=your_supabase_url
      SUPABASE_ANON_KEY=your_supabase_anon_key
      ```

5.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

## How to Run the Project

- **From the Terminal**:
  ```bash
  flutter run
  ```
- **Using VS Code**:
  - Open the project in VS Code.
  - Select a target device (emulator or physical device).
  - Press `F5` or go to `Run` > `Start Debugging`.

## Folder Structure

\`\`\`
lib/
├── main.dart
├── auth/
│   ├── auth_gate.dart
│   ├── auth_service.dart
│   ├── login_screen.dart
│   └── signup_screen.dart
├── core/
│   ├── constants/
│   └── theme/
├── features/
│   ├── games/
│   ├── home/
│   ├── learn/
│   ├── play/
│   ├── profile/
│   └── progress/
└── navigation/
    └── bottom_nav.dart
\`\`\`

## Key Components / Modules

- **`AuthGate`**: The central point for handling user authentication state.
- **`AuthService`**: A service class that abstracts all authentication logic.
- **`BottomNav`**: The main navigation widget for the app after login.
- **`HomeScreen`**: The landing page, providing daily content and user stats.
- **Game Screens**: Each game has a dedicated screen that contains its UI and logic.

## Dependencies

- `supabase_flutter`: For backend integration.
- `flutter_dotenv`: For environment variable management.
- `google_fonts`: For custom typography.
- `confetti`: For celebratory animations.
- `flutter_tts`: For text-to-speech functionality.
- `shared_preferences`: For local data persistence.
- `cupertino_icons`: For iOS-style icons.

## Challenges Faced and Solutions

- **Challenge**: Managing user state consistently across the app.
- **Solution**: Used Supabase's real-time auth stream with a `StreamBuilder` in `AuthGate` to reactively switch between auth and main app screens.

- **Challenge**: Ensuring a consistent "Shloka of the Day" for all users.
- **Solution**: Implemented a deterministic algorithm that uses the day of the year to select a shloka, avoiding the need for a daily server-side cron job.

- **Challenge**: Persisting game progress without complex state management.
- **Solution**: Leveraged `shared_preferences` to locally save and retrieve game state like levels and scores, which is simple and effective for this use case.

## Results / Output

The result is a polished, functional, and engaging mobile application that successfully gamifies the learning of the Bhagavad Gita. The app provides a seamless user experience from authentication to gameplay and is ready for deployment on both iOS and Android platforms.

## Future Scope

- **Content Expansion**: Add more shlokas, chapters, and games.
- **Enhanced Progress Tracking**: Implement detailed analytics and visualizations for the `Progress` screen.
- **Community Features**: Add leaderboards, social sharing, and discussion forums.
- **AI Integration**: Use AI to provide personalized learning paths and explanations.
- **Localization**: Add support for more languages.
- **Backend Content Management**: Move hardcoded game content to the Supabase database to allow for dynamic updates without releasing a new app version.

## Conclusion

The Learn Geeta project is a successful demonstration of how modern technology can be used to preserve and spread ancient wisdom. By combining Flutter's powerful UI capabilities with Supabase's robust backend services, we have created an application that is not only educational but also fun and inspiring to use.

## Acknowledgements

- The Flutter and Supabase communities for their excellent documentation and support.
- The creators of the open-source packages used in this project.
