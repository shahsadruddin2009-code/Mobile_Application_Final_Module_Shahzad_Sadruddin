# 💪 Muscle Power - Bodybuilding & Fitness Tracking App

A comprehensive Flutter-based bodybuilding and fitness tracking application designed to help users achieve their fitness goals through structured workouts, nutrition tracking, and progress monitoring.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Windows-green)
![Tests](https://img.shields.io/badge/Tests-616%20Passing-brightgreen)
![Coverage](https://img.shields.io/badge/Coverage-45%25-yellow)
![Version](https://img.shields.io/badge/Version-1.1.0-orange)

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

### 🔔 Notifications & Engagement
- **Smart Notifications**: Contextual reminders for training, nutrition, and progress
- **Weekly Challenges**: Stay motivated with fitness challenges
- **Notification Center**: Bell icon on home screen opens a curated notification sheet

### 📈 Test Statistics Dashboard
- **Quality Assurance Profile**: Dedicated screen visualizing all test metrics
- **Interactive Charts**: Pass rate ring, coverage bars, and category breakdowns
- **Expandable Test Groups**: Drill down into individual test group details
- **Coverage by Layer**: Visual breakdown across Models, Services, Screens, and Widgets

### 🎨 Modern UI/UX
- **Dark Theme**: Eye-friendly dark mode design with orange (#FF6B35) and cyan (#00D9FF) accents
- **Smooth Animations**: Fade transitions, pulsing icons, shimmer loading effects
- **Responsive Design**: Works on phones, tablets, and desktop
- **Custom Typography**: Beautiful fonts using Google Fonts (Poppins)
- **6-Tab Navigation**: Home, Workouts, Exercises, Progress, Nutrition, Profile

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
├── main.dart                        # App entry point, theme & 6-tab navigation
├── data/
│   └── data_service.dart            # Static data provider (workouts, exercises, meals)
├── models/
│   └── models.dart                  # Data models (Exercise, Workout, User, Meal, etc.)
├── screens/
│   ├── landing_screen.dart          # Welcome/onboarding screen
│   ├── auth_screen.dart             # Login/registration screen (email + social)
│   ├── home_screen.dart             # Main dashboard with notifications & quick actions
│   ├── workouts_screen.dart         # Workout library & custom workout creation
│   ├── workout_detail_screen.dart   # Individual workout view with exercise list
│   ├── exercises_screen.dart        # Exercise library by muscle group
│   ├── exercise_detail_screen.dart  # Individual exercise view with form tips
│   ├── progress_screen.dart         # Progress tracking & interactive charts
│   ├── nutrition_screen.dart        # Meal & nutrition tracking with macros
│   ├── profile_screen.dart          # User profile management
│   └── test_statistics_screen.dart  # QA dashboard — test metrics & coverage visuals
├── services/
│   ├── auth_service.dart            # Authentication & session management
│   ├── database_service.dart        # SQLite database operations
│   ├── progress_service.dart        # Progress data management
│   ├── nutrition_service.dart       # Nutrition/meal logging
│   ├── exercise_log_service.dart    # Exercise set logging
│   ├── custom_workout_service.dart  # Custom workout CRUD
│   ├── encryption_service.dart      # SHA-256 hashing & XOR encryption
│   ├── performance_service.dart     # App performance monitoring & SLOs
│   ├── health_dashboard_service.dart # Health monitoring, crash tracking & alerts
│   ├── feedback_service.dart        # User feedback, NPS surveys & support tickets
│   ├── connectivity_service.dart    # Network connectivity monitoring
│   ├── api_client.dart              # Centralised HTTP client with retry logic
│   ├── cache_manager.dart           # LRU cache with TTL & persistence
│   ├── data_lifecycle_service.dart  # GDPR consent, retention & data export
│   └── app_lifecycle_observer.dart  # App lifecycle event tracking
└── widgets/
    ├── gradient_card.dart           # Reusable gradient card & glass card widgets
    ├── stat_card.dart               # Statistics display cards (animated, circular, mini)
    ├── exercise_illustration.dart   # Animated exercise custom paint illustrations
    ├── bodybuilder_animation.dart   # Animated fitness figure background decoration
    ├── offline_banner.dart          # Connectivity-aware offline indicator banner
    └── responsive_helper.dart       # Responsive breakpoints, font & spacing utilities

test/
├── widget_test.dart                 # Legacy widget tests (7 tests)
├── data/
│   └── data_service_test.dart       # Data service unit tests (41 tests)
├── models/
│   └── models_test.dart             # Model unit tests (21 tests)
├── services/
│   ├── encryption_service_test.dart         # Encryption unit tests (49 tests)
│   ├── exercise_log_service_test.dart       # Exercise log unit tests (28 tests)
│   ├── nutrition_service_test.dart          # Nutrition service unit tests (24 tests)
│   ├── progress_service_test.dart           # Progress service unit tests (39 tests)
│   ├── custom_workout_service_test.dart     # Custom workout unit tests (24 tests)
│   ├── feedback_service_test.dart           # Feedback & NPS survey tests (42 tests)
│   ├── performance_service_test.dart        # Performance monitoring tests (38 tests)
│   ├── health_dashboard_service_test.dart   # Health dashboard & SLO tests (45 tests)
│   ├── api_client_test.dart                 # API client & rate limiting tests (12 tests)
│   ├── cache_manager_test.dart              # Cache TTL & LRU eviction tests (10 tests)
│   ├── connectivity_service_test.dart       # Connectivity monitoring tests (5 tests)
│   └── data_lifecycle_service_test.dart     # GDPR & data lifecycle tests (15 tests)
├── widgets/
│   ├── gradient_card_test.dart          # GradientCard widget tests (28 tests)
│   ├── stat_card_test.dart              # StatCard widget tests (23 tests)
│   ├── responsive_helper_test.dart      # Responsive breakpoint tests (28 tests)
│   ├── exercise_illustration_test.dart  # Exercise illustration tests (22 tests)
│   ├── bodybuilder_animation_test.dart  # Bodybuilder animation tests (12 tests)
│   └── offline_banner_test.dart         # Offline banner tests (10 tests)
├── screens/
│   ├── auth_screen_test.dart            # Auth screen widget tests (19 tests)
│   ├── landing_screen_test.dart         # Landing screen widget tests (9 tests)
│   ├── main_navigation_test.dart        # Navigation widget tests (15 tests)
│   └── test_statistics_screen_test.dart # QA dashboard widget tests (89 tests)
└── integration/
    ├── service_integration_test.dart    # Cross-service integration (27 tests)
    └── app_integration_test.dart        # Full app integration (16 tests)
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

## 🧪 Testing

### Test Summary

| Metric                | Value        |
|-----------------------|--------------|
| **Total Tests**       | 616          |
| **Passed**            | 616          |
| **Failed**            | 0            |
| **Pass Rate**         | 100%         |
| **Test Files**        | 23           |
| **Test Groups**       | 110+         |
| **Total Test LOC**    | ~9,200       |
| **Execution Time**    | ~30 seconds  |

### Test Categories

| Category             | Files | Tests | Description                                    |
|----------------------|------:|------:|------------------------------------------------|
| **Unit Tests**       |    10 |   351 | Models, services, encryption, data layer, feedback, perf, health |
| **Widget Tests**     |     9 |   255 | Screen rendering, widget behavior, responsiveness, animations    |
| **Integration Tests**|     2 |    43 | Cross-service flows, full app navigation       |
| **Legacy Tests**     |     1 |     7 | Original widget test scaffold                  |

### Running Tests

```bash
# Run all tests
flutter test

# Run with expanded output
flutter test --reporter expanded

# Run with coverage
flutter test --coverage

# Run a specific test file
flutter test test/screens/test_statistics_screen_test.dart

# Run tests matching a name pattern
flutter test --name "Encryption"
```

### Code Coverage Overview

**Overall: ~4,700 / 10,485 executable lines (~45%)**

| Layer           | Coverage | Status |
|-----------------|----------|--------|
| Models          | 100.0%   | ✅ Full |
| Data            | 100.0%   | ✅ Full |
| Services        | 78.5%    | 🟢 High |
| App (main.dart) | 82.5%    | 🟢 High |
| Screens         | 40.1%    | 🟡 Partial |
| Widgets         | 52.3%    | 🟡 Partial |

#### Fully Covered Files (100%)
- `models.dart` — 21 tests, 9/9 lines
- `data_service.dart` — 41 tests, 141/141 lines
- `encryption_service.dart` — 49 tests, 91/91 lines

#### Near-Full Coverage (>95%)
- `custom_workout_service.dart` — 98.9%
- `landing_screen.dart` — 98.4%
- `nutrition_service.dart` — 98.1%
- `stat_card.dart` — 96.8%
- `gradient_card.dart` — 95.0%

> For the complete test statistics breakdown, see [`test/TEST_STATISTICS_PROFILE.md`](test/TEST_STATISTICS_PROFILE.md) or launch the in-app **Test Statistics Dashboard** from the profile screen.

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

Mobile Application Development - Final Module Assessment

*Last Updated: February 18, 2026*

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
