# 💪 Iron Forge - Bodybuilding & Fitness Tracking App

A comprehensive Flutter-based bodybuilding and fitness tracking application designed to help users achieve their fitness goals through structured workouts, nutrition tracking, and progress monitoring.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Windows-green)
![Version](https://img.shields.io/badge/Version-1.0.0-orange)

---

## 📱 Screenshots

The app features a modern dark theme with orange and cyan accent colors, providing an immersive fitness experience.

---

## ✨ Features

### 🏋️ Workout Management
- **Pre-built Workouts**: Access a library of professionally designed workout routines
- **Custom Workouts**: Create and save your own personalized workout plans
- **Exercise Library**: Browse exercises categorized by muscle group (Chest, Back, Arms, Legs, Shoulders, Core)
- **Workout Logging**: Track completed workouts with sets, reps, and weights
- **Workout Timer**: Built-in rest timer between sets

### 📊 Progress Tracking
- **Daily Progress**: Visual circular progress indicators for today's achievements
- **Statistics Dashboard**: View total workouts, time spent, and calories burned
- **Body Measurements**: Log weight and body measurements over time
- **Progress Charts**: Visualize your fitness journey with interactive charts (fl_chart)
- **Weekly Challenges**: Stay motivated with weekly fitness challenges

### 🥗 Nutrition Tracking
- **Meal Logging**: Track daily meals and calorie intake
- **Macro Tracking**: Monitor protein, carbs, and fat consumption
- **Meal Plans**: Follow structured meal plans for your fitness goals
- **Calorie Calculator**: Estimate calories burned during workouts

### 👤 User Profile & Authentication
- **Email/Password Authentication**: Secure account creation and login
- **Social Login**: Sign in with Google, Apple, or Facebook
- **Profile Management**: Customize your profile with personal details
- **Session Persistence**: Stay logged in across app sessions

### 🎨 Modern UI/UX
- **Dark Theme**: Eye-friendly dark mode design
- **Smooth Animations**: Polished transitions and micro-interactions
- **Responsive Design**: Works on phones, tablets, and desktop
- **Custom Typography**: Beautiful fonts using Google Fonts (Poppins)

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.0+ |
| **Language** | Dart 3.0+ |
| **State Management** | StatefulWidget with Services |
| **Local Database** | SQLite (sqflite) |
| **Preferences** | SharedPreferences |
| **Charts** | fl_chart |
| **Progress Indicators** | percent_indicator |
| **Calendar** | table_calendar |
| **Typography** | Google Fonts |
| **Date Formatting** | intl |

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point & theme configuration
├── data/
│   └── data_service.dart        # Static data provider (workouts, exercises)
├── models/
│   └── models.dart              # Data models (Exercise, Workout, User, etc.)
├── screens/
│   ├── landing_screen.dart      # Welcome/onboarding screen
│   ├── auth_screen.dart         # Login/registration screen
│   ├── home_screen.dart         # Main dashboard
│   ├── workouts_screen.dart     # Workout library
│   ├── workout_detail_screen.dart # Individual workout view
│   ├── exercises_screen.dart    # Exercise library
│   ├── exercise_detail_screen.dart # Individual exercise view
│   ├── progress_screen.dart     # Progress tracking & charts
│   ├── nutrition_screen.dart    # Meal & nutrition tracking
│   └── profile_screen.dart      # User profile management
├── services/
│   ├── auth_service.dart        # Authentication & session management
│   ├── database_service.dart    # SQLite database operations
│   ├── progress_service.dart    # Progress data management
│   ├── nutrition_service.dart   # Nutrition/meal logging
│   ├── exercise_log_service.dart # Exercise set logging
│   └── custom_workout_service.dart # Custom workout management
└── widgets/
    ├── gradient_card.dart       # Reusable gradient card widget
    ├── stat_card.dart           # Statistics display card
    └── exercise_illustration.dart # Exercise image display
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- (Optional) Xcode for iOS development

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd bodybuilding_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For development
   flutter run

   # For specific platform
   flutter run -d chrome      # Web
   flutter run -d windows     # Windows
   flutter run -d android     # Android emulator
   flutter run -d ios         # iOS simulator
   ```

4. **Build for release**
   ```bash
   flutter build apk          # Android APK
   flutter build appbundle    # Android App Bundle
   flutter build ios          # iOS
   flutter build web          # Web
   flutter build windows      # Windows
   ```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.6        # iOS-style icons
  google_fonts: ^6.1.0           # Custom typography
  percent_indicator: ^4.2.3      # Circular/linear progress indicators
  fl_chart: ^0.66.0              # Interactive charts
  intl: ^0.19.0                  # Date/number formatting
  sqflite: ^2.3.0                # SQLite database
  path: ^1.8.3                   # File path utilities
  shared_preferences: ^2.2.2     # Key-value storage
  table_calendar: ^3.1.0         # Calendar widget
  google_sign_in: ^6.2.1         # Google authentication
  sign_in_with_apple: ^6.1.0     # Apple authentication
  flutter_facebook_auth: ^7.0.0  # Facebook authentication
```

---

## 🔐 Authentication

The app supports multiple authentication methods:

| Method | Status | Notes |
|--------|--------|-------|
| Email/Password | ✅ Active | Full registration and login |
| Google Sign-In | ✅ Active | OAuth 2.0 integration |
| Apple Sign-In | ✅ Active | iOS/macOS only |
| Facebook Login | ✅ Active | Meta OAuth integration |

> **Note**: For demo purposes, passwords are stored locally. Production deployments should use proper encryption and backend authentication services like Firebase Auth.

---

## 💾 Data Storage

### Mobile/Desktop (SQLite)
- User accounts and profiles
- Workout history and logs
- Exercise performance data
- Progress measurements
- Meal/nutrition logs

### Web & Cross-Platform (SharedPreferences)
- Session persistence
- User preferences
- Quick authentication state

---

## 🎯 Data Models

### Exercise
- ID, name, muscle group, description
- Sets, reps, rest time
- Difficulty level, equipment needed
- Form tips and instructions

### Workout
- Collection of exercises
- Duration, difficulty, target muscles
- Estimated calories burned

### ProgressEntry
- Weight, body measurements
- Date tracking
- Historical data for charts

### Meal
- Food items, calories, macros
- Meal type (breakfast, lunch, dinner, snack)
- Date and time logging

---

## 🌐 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Supported | API 21+ (Android 5.0+) |
| iOS | ✅ Supported | iOS 12.0+ |
| Web | ✅ Supported | Modern browsers |
| Windows | ✅ Supported | Windows 10+ |
| macOS | 🔄 Partial | Requires setup |
| Linux | 🔄 Partial | Requires setup |

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Shahzad Sadruddin** - Student ID: 2513806

Mobile Application Development - Mid Module Assessment

---

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Material Design Guidelines](https://material.io/design)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Google Fonts for beautiful typography
- Open-source community for the excellent packages
- Fitness enthusiasts who inspired this app

---

<p align="center">Made with ❤️ and Flutter</p>
