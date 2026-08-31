# 🚗 Saudi Driving Theory Test

> Master driving theory with confidence. No constant internet required. Learn anytime, anywhere.

A beautiful, offline-first mobile app that helps you prepare for the **Saudi driving license theory exam**. Practice with realistic questions, follow a guided learning journey, master traffic signs, and simulate the real exam — all in your pocket.

![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-Proprietary-red)

---

## ✨ Features

### 🎯 Guided Learning Journey
A step-by-step curriculum organized into **stages → modules → lessons**, with comprehension quizzes after each module. Progress unlocks as you learn, keeping you on track to exam readiness.

### 📖 Comprehensive Theory Handbook
The full official handbook content — licenses, traffic rules, road signs, intersections, speed limits, and overtaking — rendered in a clean, readable format across **5 languages** (English, العربية, اردو, हिन्दी, বাংলা).

### 🧠 Practice Quizzes
- Practice by category or mode
- Instant answers with explanations
- Mistake review & spaced-repetition review queue
- Weak-area detection

### ⏱️ Real Exam Simulator
- Three modes: Quick, Standard, Full
- Realistic countdown timer (survives backgrounding)
- Strict-mode navigation
- Detailed results with score ring, category breakdown, and review

### 🚸 Traffic Signs
- Full Saudi road-sign library with search & filters
- Interactive flashcards
- Sign category reference (shape, colors, purpose)

### 📊 Progress & Stats
- Streaks, accuracy, and learning analytics
- Exam history
- Certificate of Readiness on passing

---

## 📱 Supported Languages

| Language  | Code |
|-----------|------|
| English   | `en` |
| العربية   | `ar` |
| اردو      | `ur` |
| हिन्दी    | `hi` |
| বাংলা     | `bn` |

---

## 🛠️ Tech Stack

- **Flutter** — cross-platform UI framework
- **Riverpod** — state management
- **go_router** — navigation
- **easy_localization** — multi-language support
- **google_mobile_ads** — AdMob monetization (banners + rewarded ads)
- **shared_preferences** — local persistence

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.4+ (Dart 3.4+)
- Android Studio / Android SDK

### Run
```bash
flutter pub get
flutter run
```

### Build Release AAB
```bash
flutter build appbundle --release
```

The signed bundle is output at:
```
build/app/outputs/bundle/release/app-release.aab
```

### Configuration
AdMob ad unit IDs are configured in `lib/services/ad_service.dart`. Update them with your own AdMob units before publishing.

---

## 🗂️ Project Structure

```
lib/
├── core/          # Theme, routing, utilities
├── data/          # Models & repositories
├── models/        # Domain models (Question, Sign)
├── presentation/  # Screens, providers, widgets
├── screens/       # Feature screens (handbook, journey, etc.)
├── services/      # AdMob service
├── state/         # Riverpod state
├── utils/         # Helpers (fonts, toast, navigation)
└── widgets/       # Shared widgets
assets/
├── i18n/          # Localization JSON files
├── data/          # Question bank & handbook data
├── signs/         # Traffic sign SVGs
└── ksa-signs/     # Saudi sign SVGs
```

---

## 📝 License

This project is proprietary. All rights reserved. The app is an independent educational tool and is **not affiliated with, endorsed by, or officially connected to** any government entity.
