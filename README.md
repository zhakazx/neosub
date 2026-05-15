# Neosub — Subscription Tracker

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.11.5+-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/platform-android%20%7C%20ios-lightgrey" alt="Platform">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
</p>

<p align="center">
  <b>A bold, offline-first subscription manager with Neo-Brutalist design.</b>
</p>

<p align="center">
  Track your recurring expenses, get timely billing reminders, and visualize your spending — all without an internet connection.
</p>

---

## Features

| Feature | Description |
|---------|-------------|
| **Dashboard** | At-a-glance view of monthly spending, active subscriptions, and upcoming bills |
| **Subscription Management** | Add, edit, and delete subscriptions with full details (price, cycle, category, notes) |
| **Renewal Calendar** | Monthly calendar view with visual indicators for billing dates |
| **Smart Reminders** | Local notifications at 7 days, 1 day, and on billing day — no server required |
| **Neo-Brutalist UI** | Bold typography, thick borders, offset shadows, and vibrant colors |
| **Dark Mode** | Fully supported dark theme with consistent brutalist aesthetics |
| **Multi-Currency** | Support for IDR, USD, EUR, GBP, SGD, and more |
| **Categories** | Organize subscriptions by Entertainment, Productivity, AI Tools, Cloud, etc. |
| **Status Tracking** | Mark subscriptions as Active, Paused, or Cancelled |

---

## Screens

| Home Dashboard | Subscriptions | Calendar | Settings |
|:---:|:---:|:---:|:---:|
| *Total spending, active count, upcoming bills* | *Full list with filters & search* | *Visual renewal schedule* | *Currency, theme, notifications* |

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.11.5`
- [Dart SDK](https://dart.dev/get-dart) `^3.0.0`
- Android SDK (for Android builds)
- Xcode (for iOS builds — macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/neosub.git
   cd neosub
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters** (if needed)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   # Android
   flutter run

   # iOS
   flutter run -d ios
   ```

---

## Architecture

Neosub follows a **layered, offline-first architecture** with clean separation of concerns:

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│   (Screens, Widgets, Neo-Brutalism  │
│    Theme, Custom UI Components)     │
├─────────────────────────────────────┤
│          Business Logic Layer       │
│   (Riverpod Providers, Routing,     │
│    Notification Scheduling)          │
├─────────────────────────────────────┤
│            Data Layer               │
│   (Repositories, Hive Adapters,      │
│    Shared Preferences)             │
├─────────────────────────────────────┤
│            Storage                  │
│        (Hive, SharedPreferences)   │
└─────────────────────────────────────┘
```

### Key Design Decisions

- **State Management**: [Riverpod 2.x](https://riverpod.dev/) — type-safe, testable, and scalable
- **Local Database**: [Hive](https://hivedb.dev/) — fast, lightweight NoSQL for offline-first storage
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) — declarative, URL-based routing with deep-link support
- **Notifications**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) — fully local, no backend required
- **Calendar**: [table_calendar](https://pub.dev/packages/table_calendar) — customizable monthly calendar widget

---

## Project Structure

```
lib/
├── main.dart                         # App entry point
├── router/
│   └── app_router.dart               # GoRouter configuration
├── screens/
│   ├── home_screen.dart               # Dashboard overview
│   ├── subscriptions_screen.dart    # Subscription list & filters
│   ├── calendar_screen.dart         # Renewal calendar
│   ├── settings_screen.dart          # App preferences
│   ├── subscription_form_screen.dart # Add / Edit subscription
│   ├── subscription_detail_screen.dart # Detail view
│   └── shell_scaffold.dart          # Bottom navigation shell
├── widgets/
│   ├── brutalist_card.dart           # Reusable card component
│   └── brutalist_button.dart         # Press-effect button
├── providers/
│   ├── subscription_provider.dart    # Subscription state
│   └── settings_provider.dart        # App settings state
├── repositories/
│   ├── subscription_repository.dart  # Subscription CRUD
│   └── settings_repository.dart      # Settings persistence
├── services/
│   ├── hive_service.dart             # Hive initialization
│   └── notification_service.dart     # Local notification scheduling
├── models/
│   ├── subscription.dart             # Subscription entity
│   ├── category.dart                 # Subscription categories
│   ├── billing_cycle.dart            # Weekly / Monthly / Yearly
│   ├── subscription_status.dart      # Active / Paused / Cancelled
│   ├── reminder_settings.dart        # Notification preferences
│   └── adapters.dart                 # Hive type adapters
├── utils/
│   ├── brutalist_theme.dart          # Light & dark theme definitions
│   └── currency.dart                 # Currency formatting helpers
```

---

## Testing

Run the test suite:

```bash
flutter test
```

For widget tests:

```bash
flutter test test/widget_test.dart
```

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `hive` & `hive_flutter` | Local NoSQL database |
| `flutter_riverpod` | Reactive state management |
| `go_router` | Declarative routing |
| `flutter_local_notifications` | Scheduled local notifications |
| `table_calendar` | Interactive calendar widget |
| `shared_preferences` | Lightweight settings storage |
| `intl` | Internationalization & date formatting |
| `uuid` | Unique identifier generation |
| `path_provider` | Device filesystem paths |
| `google_fonts` | Custom web fonts |
| `timezone` | Timezone-aware scheduling |

See [`pubspec.yaml`](pubspec.yaml) for the complete dependency list.

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- [Flutter Team](https://flutter.dev) for the amazing framework
- [Hive](https://hivedb.dev/) contributors for blazing-fast local storage
- The Neo-Brutalism design community for the bold aesthetic inspiration

---

<p align="center">
  Developed by <a href="https://github.com/zhakazx">ZhakaZx</a>.
</p>
