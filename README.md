# Busana Nusantara - Quiz Game

A Flutter quiz application about Indonesian traditional clothing (Pakaian Adat).

## Features

- 🎮 Interactive quiz with 15 questions about Indonesian traditional clothing
- 🎯 Three difficulty levels (Easy, Medium, Hard)
- 📊 Score tracking and best score persistence
- 🎨 Material 3 design with dark navy (#0B1320) and gold (#D4AF37) theme
- ✨ Smooth animations and transitions
- 📱 Responsive UI optimized for mobile devices

## Requirements

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)

## Installation & Setup

1. **Clone or navigate to the project directory**
   ```bash
   cd "c:\Users\Hype AMD\Documents\ex quiz pakaian adat"
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

   For web:
   ```bash
   flutter run -d chrome
   ```

   For Android/iOS emulator or connected device:
   ```bash
   flutter devices  # List available devices
   flutter run -d <device_id>
   ```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # App configuration & routing
├── models/
│   └── question.dart            # Question data model
├── providers/
│   └── quiz_provider.dart       # Riverpod state management
├── services/
│   └── question_loader.dart     # JSON question loader
└── screens/
    ├── splash_screen.dart       # Splash screen with auto-navigation
    ├── difficulty_screen.dart   # Difficulty selection
    ├── quiz_screen.dart         # Main quiz interface
    └── result_screen.dart       # Results display

assets/
├── data/
│   └── questions.json           # Quiz questions data
└── images/                      # Traditional clothing images (placeholders)
```

## Dependencies

- **go_router** (^14.0.0) - Declarative routing
- **flutter_riverpod** (^2.5.0) - State management
- **shared_preferences** (^2.2.0) - Local storage for best scores

## How to Play

1. Launch the app and wait for the splash screen
2. Select your difficulty level (Easy/Medium/Hard)
3. Answer 15 questions about Indonesian traditional clothing
4. Each correct answer awards 10 points
5. View your final score and compare with your best score
6. Play again to improve your score!

## Scoring System

- Correct answer: +10 points
- Wrong answer: +0 points
- Maximum score: 150 points (15 questions × 10 points)
- Best scores are saved per difficulty level

## Note on Images

The current version uses icon placeholders for traditional clothing images. To add real images:
1. Place JPG/PNG images in `assets/images/` directory
2. Name them according to the JSON file references (e.g., `payas_agung.jpg`)
3. Images are automatically loaded from the JSON data

## Troubleshooting

**Issue: Dependencies not resolving**
```bash
flutter clean
flutter pub get
```

**Issue: App not running**
- Ensure Flutter SDK is properly installed: `flutter doctor`
- Check that your device/emulator is connected: `flutter devices`

**Issue: Assets not loading**
- Verify `pubspec.yaml` has correct asset paths
- Run `flutter clean` and rebuild

## Credits

Developed with Flutter & Material 3
Traditional clothing knowledge: Indonesian cultural heritage
