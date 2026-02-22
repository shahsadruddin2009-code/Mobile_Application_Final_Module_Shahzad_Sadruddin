# MUSCLE POWER - Test Statistics Profile

## Test Execution Summary

| Metric                | Value       |
|-----------------------|-------------|
| **Total Tests**       | 653         |
| **Passed**            | 653         |
| **Failed**            | 0           |
| **Pass Rate**         | 100%        |
| **Test Files**        | 27          |
| **Test Groups**       | 110+        |
| **Total Test LOC**    | 7,992       |
| **Total Source LOC**  | 30,514      |
| **Test-to-Code Ratio**| 0.26:1     |
| **Execution Time**    | ~36 seconds |

---

## Test Categories Breakdown

### Unit Tests (11 files — 398 tests)

| # | Test File                              | Tests | Groups | LOC | Status |
|---|----------------------------------------|-------|--------|-----|--------|
| 1 | `test/models/models_test.dart`         |    21 |      9 | 495 |   PASS |
| 2 | `test/services/encryption_service_test.dart` | 49 |  9 | 363 |   PASS |
| 3 | `test/services/exercise_log_service_test.dart` | 28 | 2 | 519 |  PASS |
| 4 | `test/services/nutrition_service_test.dart` |  24 |  2 | 261 |   PASS |
| 5 | `test/services/progress_service_test.dart`  |  39 |  3 | 485 |   PASS |
| 6 | `test/services/custom_workout_service_test.dart` | 24 | 2 | 324 | PASS |
| 7 | `test/data/data_service_test.dart`      |    41 |      7 | 374 |   PASS |
| 8 | `test/screens/test_statistics_screen_test.dart` | 89 | 10 | 676 | PASS |
| 9 | `test/services/feedback_service_test.dart` |  42 |  10 | 385 |   PASS |
|10 | `test/services/performance_service_test.dart` | 38 | 9 | 262 |  PASS |
|11 | `test/services/health_dashboard_service_test.dart` | 45 | 11 | 340 | PASS |

### Widget / Screen Tests (8 files — 166 tests)

| # | Test File                              | Tests | Groups | LOC | Status |
|---|----------------------------------------|-------|--------|-----|--------|
| 1 | `test/widgets/gradient_card_test.dart`  |    28 |      5 | 432 |   PASS |
| 2 | `test/widgets/stat_card_test.dart`      |    23 |      4 | 443 |   PASS |
| 3 | `test/screens/auth_screen_test.dart`    |    19 |      5 | 184 |   PASS |
| 4 | `test/screens/landing_screen_test.dart` |     9 |      1 |  82 |   PASS |
| 5 | `test/screens/main_navigation_test.dart`|    15 |      2 | 163 |   PASS |
| 6 | `test/widgets/responsive_helper_test.dart` | 28 |   7 | 265 |   PASS |
| 7 | `test/widgets/exercise_illustration_test.dart` | 22 | 4 | 196 | PASS |
| 8 | `test/widgets/bodybuilder_animation_test.dart` | 12 | 3 | 142 | PASS |

### Additional Service Tests (4 files — 42 tests)

| # | Test File                                        | Tests | Groups | LOC | Status |
|---|--------------------------------------------------|-------|--------|-----|--------|
| 1 | `test/services/api_client_test.dart`              |    12 |      5 | 139 |   PASS |
| 2 | `test/services/cache_manager_test.dart`            |    10 |      5 | 110 |   PASS |
| 3 | `test/services/connectivity_service_test.dart`     |     5 |      3 |  42 |   PASS |
| 4 | `test/services/data_lifecycle_service_test.dart`   |    15 |      5 | 145 |   PASS |

### Other Widget Tests (1 file — 10 tests)

| # | Test File                              | Tests | Groups | LOC | Status |
|---|----------------------------------------|-------|--------|-----|--------|
| 1 | `test/widgets/offline_banner_test.dart` |    10 |      5 | 146 |   PASS |

### Integration Tests (2 files — 43 tests)

| # | Test File                                   | Tests | Groups | LOC | Status |
|---|---------------------------------------------|-------|--------|-----|--------|
| 1 | `test/integration/service_integration_test.dart` | 27 |  6 | 564 |   PASS |
| 2 | `test/integration/app_integration_test.dart`     | 16 | 11 | 328 |   PASS |

### Legacy Tests (1 file — 7 tests)

| # | Test File                | Tests | Groups | LOC | Status |
|---|--------------------------|-------|--------|-----|--------|
| 1 | `test/widget_test.dart`  |     7 |      0 | 127 |   PASS |

---

## Code Coverage Profile

**Overall Coverage: 6,801 / 13,071 executable lines (52.0%)**

### Per-File Coverage

| Source File                           | Lines Hit | Lines Found | Coverage |
|---------------------------------------|-----------|-------------|----------|
| `lib/data/data_service.dart`          |       143 |         143 |  100.0%  |
| `lib/models/models.dart`              |         9 |           9 |  100.0%  |
| `lib/services/encryption_service.dart`|        91 |          91 |  100.0%  |
| `lib/widgets/bodybuilder_animation.dart`|     490 |         490 |  100.0%  |
| `lib/widgets/responsive_helper.dart`  |        29 |          29 |  100.0%  |
| `lib/screens/test_statistics_screen.dart`|     445 |         446 |   99.8%  |
| `lib/services/custom_workout_service.dart` |  92 |          93 |   98.9%  |
| `lib/screens/landing_screen.dart`     |       121 |         123 |   98.4%  |
| `lib/services/nutrition_service.dart`  |      102 |         105 |   97.1%  |
| `lib/widgets/stat_card.dart`          |        94 |          97 |   96.9%  |
| `lib/widgets/gradient_card.dart`      |       115 |         121 |   95.0%  |
| `lib/services/progress_service.dart`  |       171 |         188 |   91.0%  |
| `lib/services/exercise_log_service.dart`|     106 |         118 |   89.8%  |
| `lib/services/data_lifecycle_service.dart`|    97 |         110 |   88.2%  |
| `lib/screens/exercises_screen.dart`   |       140 |         165 |   84.8%  |
| `lib/services/feedback_service.dart`  |       231 |         299 |   77.3%  |
| `lib/services/cache_manager.dart`     |        74 |          99 |   74.7%  |
| `lib/widgets/offline_banner.dart`     |        23 |          31 |   74.2%  |
| `lib/services/health_dashboard_service.dart`| 211 |         304 |   69.4%  |
| `lib/services/performance_service.dart`|     152 |         237 |   64.1%  |
| `lib/main.dart`                       |        55 |          88 |   62.5%  |
| `lib/widgets/exercise_illustration.dart`|   2,439 |       4,440 |   54.9%  |
| `lib/screens/profile_screen.dart`     |       201 |         407 |   49.4%  |
| `lib/screens/home_screen.dart`        |       239 |         513 |   46.6%  |
| `lib/services/api_client.dart`        |        48 |         111 |   43.2%  |
| `lib/screens/auth_screen.dart`        |       212 |         493 |   43.0%  |
| `lib/services/connectivity_service.dart`|      11 |          26 |   42.3%  |
| `lib/screens/progress_screen.dart`    |       303 |         724 |   41.9%  |
| `lib/screens/workouts_screen.dart`    |       129 |         371 |   34.8%  |
| `lib/screens/nutrition_screen.dart`   |       198 |         586 |   33.8%  |
| `lib/services/auth_service.dart`      |        27 |         323 |    8.4%  |
| `lib/screens/privacy_screen.dart`     |         1 |         135 |    0.7%  |
| `lib/screens/performance_dashboard_screen.dart`| 1 |       347 |    0.3%  |
| `lib/screens/feedback_screen.dart`    |         1 |         504 |    0.2%  |
| `lib/services/app_lifecycle_observer.dart`|     0 |          24 |    0.0%  |
| `lib/screens/exercise_detail_screen.dart`|      0 |         368 |    0.0%  |
| `lib/screens/workout_detail_screen.dart`|       0 |         313 |    0.0%  |

### Coverage by Layer

| Layer               | Lines Hit | Lines Found | Coverage |
|---------------------|-----------|-------------|----------|
| **Models**          |         9 |           9 |  100.0%  |
| **Data**            |       143 |         143 |  100.0%  |
| **Services**        |     1,413 |       2,104 |   67.2%  |
| **Widgets**         |     3,190 |       5,208 |   61.3%  |
| **Screens**         |     1,991 |       5,495 |   36.2%  |
| **App (main.dart)** |        55 |          88 |   62.5%  |

---

## Feature Coverage Matrix

| App Feature                  | Unit Tests | Widget Tests | Integration Tests | Coverage  |
|------------------------------|:----------:|:------------:|:-----------------:|:---------:|
| **Models / Data Classes**    |     21     |      —       |        —          |  100.0%   |
| **Encryption / Security**    |     49     |      —       |        5          |  100.0%   |
| **Exercise Logging**         |     28     |      —       |        3          |   89.8%   |
| **Nutrition Tracking**       |     24     |      —       |        3          |   98.1%   |
| **Progress Tracking**        |     39     |      —       |        4          |   91.0%   |
| **Custom Workouts**          |     24     |      —       |        4          |   98.9%   |
| **Data Service (Static)**    |     41     |      —       |        4          |  100.0%   |
| **SQL Injection Protection** |     15     |      —       |        —          |  100.0%   |
| **Test Statistics Screen**   |     89     |      —       |        —          |   99.8%   |
| **GradientCard Widgets**     |      —     |     28       |        —          |   95.0%   |
| **StatCard Widgets**         |      —     |     23       |        —          |   96.8%   |
| **Auth Screen**              |      —     |     19       |        2          |   43.0%   |
| **Landing Screen**           |      —     |      9       |        3          |   98.4%   |
| **Navigation (6-tab)**       |      —     |     15       |        3          |   82.5%   |
| **Home Screen**              |      —     |      —       |        1          |   46.5%   |
| **Workouts Screen**          |      —     |      —       |        1          |   34.4%   |
| **Exercises Screen**         |      —     |      —       |        1          |   84.3%   |
| **Nutrition Screen**         |      —     |      —       |        1          |   33.8%   |
| **Feedback Service**         |     42     |      —       |        —          |    —      |
| **Performance Service**      |     38     |      —       |        —          |    —      |
| **Health Dashboard Service** |     45     |      —       |        —          |    —      |
| **Responsive Helper**        |      —     |     28       |        —          |    —      |
| **Exercise Illustration**    |      —     |     22       |        —          |    —      |
| **Bodybuilder Animation**    |      —     |     12       |        —          |    —      |
| **Offline Banner**           |      —     |     10       |        —          |    —      |
| **API Client**               |     12     |      —       |        —          |    —      |
| **Cache Manager**            |     10     |      —       |        —          |    —      |
| **Connectivity Service**     |      5     |      —       |        —          |    —      |
| **Data Lifecycle Service**   |     15     |      —       |        —          |    —      |
| **App Integration Flows**    |      —     |      —       |       16          |    —      |

---

## Test Groups Detail

### Models (21 tests)
- Exercise model — 3 tests
- Workout model — 2 tests
- SetLog model — 2 tests
- ExerciseLog model — 2 tests
- WorkoutLog model — 2 tests
- UserProfile model — 3 tests
- Meal model — 3 tests
- MealPlan model — 2 tests
- ProgressEntry model — 2 tests

### Encryption Service (49 tests)
- Singleton pattern — 2 tests
- Salt generation — 4 tests
- Password hashing — 7 tests
- Password verification — 7 tests
- Field encryption — 5 tests
- Field decryption — 5 tests
- isEncrypted detection — 6 tests
- encryptIfNeeded guard — 5 tests
- End-to-end flows — 8 tests

### Exercise Log Service (28 tests)
- ExerciseLogEntry model — 7 tests
- ExerciseLogService CRUD & queries — 21 tests

### Nutrition Service (24 tests)
- MealLog model — 6 tests
- NutritionService operations — 18 tests

### Progress Service (39 tests)
- UserBodyStats BMI calculations — 7 tests
- ProgressEntry model — 6 tests
- ProgressService operations — 26 tests

### Custom Workout Service (24 tests)
- CustomWorkout model — 7 tests
- CustomWorkoutService operations — 17 tests

### Data Service (41 tests)
- getExercises() validation — 5 tests
- getWorkouts() validation — 5 tests
- getMeals() validation — 6 tests
- getProgressHistory() validation — 4 tests
- getUserProfile() validation — 6 tests
- SQL Injection Protection — 15 tests

### Widget Tests - GradientCard (28 tests)
- GradientCard rendering — 6 tests
- GlassCard rendering — 5 tests
- AnimatedGradientButton — 7 tests
- PulsingIcon animation — 5 tests
- ShimmerLoading animation — 5 tests

### Widget Tests - StatCard (23 tests)
- StatCard rendering — 5 tests
- AnimatedStatCard — 6 tests
- CircularStatCard — 7 tests
- MiniStatChip — 5 tests

### Screen Tests - AuthScreen (19 tests)
- Sign In mode — 5 tests
- Sign Up mode — 4 tests
- Mode toggle switching — 4 tests
- Email validation — 3 tests
- Social login buttons — 3 tests

### Screen Tests - LandingScreen (9 tests)
- Brand display, tagline, buttons, features — 9 tests

### Screen Tests - MainNavigation (15 tests)
- BodybuildingApp setup — 3 tests
- Tab navigation (6 tabs) — 12 tests

### Integration - Service (27 tests)
- Auth + Encryption flows — 5 tests
- ExerciseLogService integration — 3 tests
- NutritionService integration — 3 tests
- ProgressService integration — 4 tests
- CustomWorkoutService integration — 4 tests
- DataService cross-validation — 4 tests
- BMI category validation — 4 tests

### Integration - App (16 tests)
- App launch flows — 2 tests
- Landing → Auth navigation — 3 tests
- 6-tab navigation flow — 2 tests
- Auth form interaction — 2 tests
- Per-tab content verification — 4 tests
- Rapid tab switching stress — 1 test
- Guest mode navigation — 1 test
- Bottom nav persistence — 1 test

### Test Statistics Screen (89 tests)
- Screen rendering and widgets — various tests
- Coverage stats model — various tests
- TestGroupInfo model — various tests

### Feedback Service (42 tests)
- FeedbackEntry model — 4 tests
- SupportTicket model — 2 tests
- TicketMessage model — 2 tests
- NpsSurveyResponse model — 4 tests
- FeedbackSummary model — 1 test
- FeedbackService singleton — 1 test
- Feedback submission — 5 tests
- NPS surveys — 4 tests
- Data access methods — 2 tests
- Summary analytics — 2 tests

### Performance Service (38 tests)
- FrameTimingData model — 2 tests
- NetworkRequestMetric model — 2 tests
- StartupMetric model — 2 tests
- PerformanceService singleton — 1 test
- SLO thresholds — 9 tests
- Startup recording — 2 tests
- Network recording — 2 tests
- Summary generation — 4 tests
- Clear all — 1 test

### Health Dashboard Service (45 tests)
- HealthAlert model — 4 tests
- AppSession model — 3 tests
- ServiceLevelObjective model — 5 tests
- HealthDashboardService singleton — 1 test
- SLO target constants — 4 tests
- Default computed rates — 5 tests
- Session tracking — 2 tests
- API call tracking — 2 tests
- Dashboard generation — 2 tests
- Alert management — 2 tests
- Clear all — 1 test

### Responsive Helper (28 tests)
- DeviceType enum — 1 test
- Breakpoint detection — 5 tests
- Value selector — 5 tests
- Font sizing — 2 tests
- Spacing helpers — 2 tests
- Grid helpers — 3 tests
- Screen dimensions — 1 test

### Exercise Illustration (22 tests)
- Widget construction — 6 tests
- Animation behaviour — 3 tests
- Exercise painter selection — 14 tests
- Widget disposal — 1 test

### Bodybuilder Animation (12 tests)
- Widget construction — 3 tests
- Rendering — 4 tests
- Lifecycle — 3 tests

### Offline Banner (10 tests)
- Widget construction — 3 tests
- Child rendering — 2 tests
- Slide transition — 1 test
- Disposal — 1 test
- Banner styling — 1 test

---

## Fully Covered Components (100%)

| Component                    | Tests | Lines | Status     |
|------------------------------|-------|-------|------------|
| `models.dart`                |    21 |     9 | 100% |
| `data_service.dart`          |    41 |   143 | 100% |
| `encryption_service.dart`    |    49 |    91 | 100% |
| `bodybuilder_animation.dart` |    12 |   490 | 100% |
| `responsive_helper.dart`     |    28 |    29 | 100% |

## Near-Full Coverage (>95%)

| Component                    | Tests | Lines | Coverage   |
|------------------------------|-------|-------|------------|
| `test_statistics_screen.dart`|    89 |   446 | 99.8% |
| `custom_workout_service.dart`|    24 |    93 | 98.9% |
| `landing_screen.dart`        |     9 |   123 | 98.4% |
| `nutrition_service.dart`     |    24 |   105 | 97.1% |
| `stat_card.dart`             |    23 |    97 | 96.9% |
| `gradient_card.dart`         |    28 |   121 | 95.0% |

---

*Generated: February 21, 2026*
*Framework: Flutter 3.38.5 + flutter_test SDK*
*Runner: `flutter test --coverage`*
*All 653 tests passed — 0 failures*
