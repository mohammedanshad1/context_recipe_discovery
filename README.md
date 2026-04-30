# 🍽️ Context Recipe Discovery

A smart Flutter recipe discovery app that suggests meals based on your **location** and **time of day** — powered by [TheMealDB API](https://www.themealdb.com/).

---

## ✨ Features

- 📍 **Location-aware suggestions** — detects your country and recommends regional cuisine
- 🕐 **Time-based meal suggestions** — Breakfast, Lunch, or Dinner based on current time
- 🔍 **Search recipes** — search by name, category, area, or ingredient
- ❤️ **Favorites** — save and manage your favorite recipes with instant UI updates
- 📖 **Full recipe details** — ingredients, measures, and step-by-step instructions
- 💾 **Offline support** — cached recipes available without internet
- 🔔 **Local notifications** — meal time reminders
- 🌐 **External links** — YouTube and source links (coming soon)
- ↕️ **Swipe to remove** — swipe left on any favorite to remove it instantly

---

## 🏗️ Architecture

This project follows **BLoC (Business Logic Component)** pattern with a clean layered structure.

```
lib/
├── bloc/
│   └── recipe_bloc.dart          # Events, States, BLoC logic
├── models/
│   └── recipe.dart               # Recipe data model
├── screens/
│   ├── splash_screen.dart        # App entry, permission requests
│   ├── home_screen.dart          # Recipe list with context-aware filters
│   ├── recipe_detail_screen.dart # Full recipe view
│   └── favorites_screen.dart     # Saved favorites (isolated from shared BLoC)
├── services/
│   ├── api_service.dart          # TheMealDB API calls
│   ├── local_storage_service.dart# SharedPreferences + favorites persistence
│   ├── location_service.dart     # Geolocator + reverse geocoding
│   └── notification_service.dart # flutter_local_notifications setup
├── widgets/
│   ├── recipe_card.dart          # Reusable card with favorite toggle
│   ├── search_bar.dart           # Search input widget
│   └── skeleton_loader.dart      # Shimmer loading placeholder
└── main.dart                     # App entry, providers setup
```

### Layer Responsibilities

| Layer | Responsibility |
|---|---|
| **BLoC** | All business logic — loading, searching, toggling favorites |
| **Services** | API calls, local storage, location, notifications |
| **Screens** | UI rendering, user interaction, navigation |
| **Widgets** | Reusable, stateless UI components |
| **Models** | Immutable data classes with `copyWith` support |

### State Management

- **`flutter_bloc`** is used for global recipe state (load, search, favorite toggle)
- **`FavoritesScreen`** manages its own local state via `setState` and reads directly from `LocalStorageService` — this prevents the shared BLoC state from being disrupted when navigating to the favorites screen
- **`RepositoryProvider`** exposes `LocalStorageService` to the widget tree so any screen can access storage without going through the BLoC

### Key Design Decisions

- **Offline-first** — every fetched recipe is cached locally; if the network fails, cached data is shown automatically
- **Favorites isolation** — the favorites screen bypasses the shared BLoC to avoid state conflicts, reading directly from `LocalStorageService`
- **Instant UI updates** — favorite removal updates the local list via `setState` before the async storage call completes, giving zero-latency feedback
- **Context-aware loading** — on startup, the app detects location and time, then loads the most relevant recipes automatically

---

## 🛠️ Tech Stack

| Package | Purpose |
|---|---|
| `flutter_bloc` | State management |
| `cached_network_image` | Efficient image loading & caching |
| `shimmer` | Skeleton loading animations |
| `shared_preferences` | Local favorites & recipe cache |
| `geolocator` | Device location access |
| `geocoding` | Reverse geocoding (coordinates → country) |
| `flutter_local_notifications` | Meal time reminders |
| `timezone` | Timezone-aware notification scheduling |
| `url_launcher` | External link handling |
| `http` | REST API calls to TheMealDB |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code with Flutter extension
- A physical device or emulator (Android/iOS)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/mohammedanshad1/context_recipe_discovery.git

# 2. Navigate into the project
cd context_recipe_discovery

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APKs by ABI (smaller size)
flutter build apk --split-per-abi --release
```

The release APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## ⚙️ CI/CD Pipeline

This project uses **GitHub Actions** for continuous integration and delivery.

### Workflow: `.github/workflows/flutter_ci.yml`

```yaml
name: Flutter CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Set up Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze code
        run: flutter analyze

      - name: Run tests
        run: flutter test

      - name: Build APK
        run: flutter build apk --release

      - name: Upload APK artifact
        uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  release:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - name: Download APK artifact
        uses: actions/download-artifact@v3
        with:
          name: release-apk

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: v${{ github.run_number }}
          name: Release v${{ github.run_number }}
          files: app-release.apk
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### CI/CD Flow

```
Push to main / PR
        │
        ▼
  flutter pub get
        │
        ▼
  flutter analyze       ← lint & static analysis
        │
        ▼
  flutter test          ← unit & widget tests
        │
        ▼
  flutter build apk     ← release APK
        │
        ▼
  Upload artifact       ← stored in GitHub Actions
        │
   (main only)
        │
        ▼
  GitHub Release        ← APK published automatically
```

---

## 📦 Releases

Download the latest APK from the [Releases](https://github.com/mohammedanshad1/context_recipe_discovery/releases) page.

---

## 🔑 Permissions

| Permission | Reason |
|---|---|
| `ACCESS_FINE_LOCATION` | Detect user's country for regional recipe suggestions |
| `ACCESS_COARSE_LOCATION` | Fallback location accuracy |
| `INTERNET` | Fetch recipes from TheMealDB API |
| `RECEIVE_BOOT_COMPLETED` | Reschedule notifications after device restart |
| `POST_NOTIFICATIONS` | Show meal time reminder notifications (Android 13+) |

---

## 🌐 API

This app uses the free [TheMealDB API](https://www.themealdb.com/api.php).

| Endpoint | Usage |
|---|---|
| `/search.php?s={query}` | Search recipes by name |
| `/filter.php?c={category}` | Filter by category |
| `/filter.php?a={area}` | Filter by area/cuisine |
| `/lookup.php?i={id}` | Fetch full recipe details |

---

## 📄 License

This project is for educational and submission purposes.

---

## 👤 Author

**Mohammed Anshad**
- GitHub: [@mohammedanshad1](https://github.com/mohammedanshad1)
