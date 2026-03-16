# WashWise

A hybrid mobile app (Android & iOS) that scans clothing care tags and tells you exactly how to wash, dry, iron, and care for each garment — no guessing, no ruined clothes.

---

## Features

- **Scan clothing tags** — point your camera at any care tag and let on-device OCR (Google ML Kit) read it instantly, no internet required
- **Handles text & symbols** — reads written instructions and lets you manually add ISO care symbols via a built-in symbol picker
- **Full care breakdown** — wash method, temperature, iron level, bleach rules, dry method, chemical compatibility
- **Step-by-step wash guide** — tailored instructions based on what the tag says
- **Do's & Don'ts** — clear colour-coded cards so nothing is ambiguous
- **Garment wardrobe** — save each garment with a photo, name, and category
- **Smart filters** — filter your wardrobe by wash method, temperature, fabric type, and chemical handling
- **100% offline** — all data stored locally on-device using Hive, no account needed

---

## Screenshots

> Coming soon once the app is built and running.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State management | Riverpod |
| Navigation | GoRouter |
| Local storage | Hive |
| OCR (on-device) | Google ML Kit Text Recognition |
| Camera | camera + image_picker |
| Platforms | Android & iOS |

---

## Project Structure

```
lib/
├── main.dart                        # Entry point, Hive init
├── app.dart                         # GoRouter setup
├── core/
│   ├── constants/
│   │   ├── app_colors.dart          # Colour palette
│   │   ├── app_theme.dart           # Material 3 theme
│   │   └── care_data.dart           # Wash guides, fabric tips, ISO symbols
│   ├── models/
│   │   ├── garment.dart             # Garment model + enums
│   │   └── care_profile.dart        # Care instruction model
│   └── utils/
│       ├── care_text_parser.dart    # OCR text → care profile parser
│       └── symbol_picker_data.dart  # 30 ISO care symbols
├── data/
│   └── garment_repository.dart      # Hive CRUD + filtering
├── features/
│   ├── scan/                        # Camera, OCR, results screen
│   ├── wardrobe/                    # Home screen, garment grid, filters
│   └── garment_detail/              # Detail view, add/edit garment
└── shared/
    └── widgets/                     # CareChip, WashGuideCard
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) v3.19+
- Android Studio (for Android) or Xcode (for iOS, macOS only)
- A physical device or emulator with camera support

Run `flutter doctor` to verify your setup.

### Installation

```bash
# 1. Clone the repo
git clone https://github.com/Ikmal14/basuhJer.git
cd basuhJer

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

> See `setup_instructions.txt` for detailed Android/iOS configuration, known issues, and release build steps.

### Android Requirements

- `minSdkVersion 21` (required by camera + ML Kit)
- Google Play Services on device (required for ML Kit OCR)
- Physical device recommended — ML Kit may not work on all emulators

### iOS Requirements

- iOS 13.0+ deployment target
- Run `cd ios && pod install` before building
- macOS + Xcode required for iOS builds

---

## How It Works

```
Camera / Gallery
      │
      ▼
Google ML Kit OCR  ──────────────────────────────────┐
(reads tag text on-device)                           │
      │                                              │
      ▼                                              ▼
CareTextParser                             Manual Symbol Picker
(regex → CareProfile)               (user taps ISO symbols to add)
      │                                              │
      └──────────────────┬──────────────────────────┘
                         ▼
                    CareProfile
         (wash method, temp, iron, bleach,
          dry method, chemicals, do/don'ts)
                         │
                         ▼
              Save to Wardrobe (Hive)
                         │
                         ▼
           Garment Detail — 4 tabs:
           How to Wash | Do's & Don'ts
           Chemicals   | Handling
```

---

## Care Symbol Support

The app includes all standard ISO 3758 care symbols across 5 categories:

| Category | Examples |
|---|---|
| Washing | Machine cold/warm/hot, hand wash, do not wash |
| Bleaching | Any bleach, non-chlorine only, no bleach |
| Drying | Tumble dry (low/med/high), line dry, flat dry, drip dry |
| Ironing | Low / medium / high heat, no iron, no steam |
| Dry Cleaning | Dry clean, gentle, do not dry clean |

---

## Data & Privacy

- All garment data is stored **locally on your device** using Hive
- No account, no login, no cloud sync
- No data ever leaves your device
- Storage location:
  - Android: `/data/data/com.washwise.app/app_flutter/`
  - iOS: `<App Documents Directory>/`

---

## Roadmap

- [ ] Flutter `flutter create` native project generation
- [ ] ISO symbol image recognition (TFLite custom model)
- [ ] Cloud backup / multi-device sync (optional)
- [ ] Laundry reminder notifications
- [ ] Fabric care tips & product recommendations
- [ ] Dark mode

---

## License

MIT License — feel free to use, modify, and distribute.
