# 🩸 BloodDonate

A Flutter-based Blood Donation MVP app that connects **donors**, **receivers**, **verifiers**, and **admins** — all with role-based access control, identity verification, and a clean feature-driven architecture.

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Local Installation](#-local-installation)
- [Running the App](#-running-the-app)
- [Testing](#-testing)
- [Demo Accounts](#-demo-accounts)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

- **Role-Based Access Control (RBAC)** — Donor, Receiver, Verifier, and Admin roles with granular permissions
- **User Authentication** — Phone-based registration and login
- **Identity Verification** — Upload ID documents, selfie, and medical docs for verification
- **Blood Requests** — Post, browse, and respond to blood donation requests
- **Role-Specific Dashboards** — Tailored dashboard for each user role
- **Notifications** — In-app notification system
- **Profile Management** — Edit profile, blood type, availability status
- **Admin Panel** — User management, banning, stats overview
- **Dark & Light Theme** — System-adaptive theming
- **Offline-First** — Local data services (no backend required for development)

---

## 🛠 Tech Stack

| Category              | Technology                          |
|-----------------------|-------------------------------------|
| Framework             | Flutter 3.x                         |
| Language              | Dart (SDK ^3.11.0)                  |
| State Management      | Riverpod (`flutter_riverpod`)       |
| Navigation            | GoRouter (`go_router`)              |
| Functional Programming| fpdart                             |
| Local Storage         | Hive, Flutter Secure Storage        |
| Animations            | Lottie, Shimmer                     |
| Camera & Images       | camera, image_picker, image_cropper |
| Code Generation       | Freezed, json_serializable          |

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/                        # App-wide core utilities
│   ├── constants/               # Colors, spacing, typography, animations
│   ├── errors/                  # Custom failure classes
│   ├── router/                  # GoRouter configuration & routes
│   └── theme/                   # Light & dark theme definitions
├── features/                    # Feature modules (clean architecture)
│   ├── auth/                    # Authentication (login, register, role selection)
│   ├── blood_requests/          # Post, browse, detail views for blood requests
│   ├── dashboard/               # Role-specific dashboards (donor/receiver/admin/verifier)
│   ├── notifications/           # In-app notifications
│   ├── profile/                 # Profile view & edit
│   └── verification/            # Document upload & verification review
├── rbac/                        # Role-based access control system
│   ├── models/                  # AppRole, AppPermission enums
│   ├── permission_guard.dart    # Route/action permission guards
│   ├── rbac_service.dart        # RBAC service logic
│   └── role_permission_matrix.dart  # Role-permission mapping
└── shared/                      # Shared across features
    ├── services/                # Local data services & models
    └── widgets/                 # Reusable widgets (scaffold, animations)
```

---

## 📦 Prerequisites

Before you begin, make sure you have the following installed:

### 1. Flutter SDK

Install Flutter **3.x** (requires Dart SDK ^3.11.0):

```bash
# Check if Flutter is installed
flutter --version

# If not installed, follow:
# https://docs.flutter.dev/get-started/install
```

### 2. Android Setup (for Android)

- **Android Studio** (latest) — [Download](https://developer.android.com/studio)
- **Android SDK** (API 34 or higher recommended)
- **Android Emulator** or a physical device with USB debugging enabled

```bash
# Verify Android toolchain
flutter doctor --android-licenses
flutter doctor
```

### 3. iOS Setup (macOS only)

- **Xcode** (latest) — Install from Mac App Store
- **CocoaPods** — `sudo gem install cocoapods`

### 4. Git

```bash
git --version
```

---

## 🚀 Local Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/pamulapoornachandra01-sudo/blooddonor-app.git
cd blooddonor-app
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Run Code Generation (if modifying models)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 4: Verify Setup

```bash
flutter doctor
```

Make sure there are no critical issues (✗) for your target platform.

---

## ▶️ Running the App

### On Android Emulator

```bash
# List available devices
flutter devices

# Run the app
flutter run
```

### On a Physical Android Device

1. Enable **Developer Options** → **USB Debugging** on your phone
2. Connect via USB
3. Run:

```bash
flutter run
```

### On Chrome (Web - for quick testing)

```bash
flutter run -d chrome
```

### On iOS Simulator (macOS only)

```bash
open -a Simulator
flutter run
```

### Build APK (Release)

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🧪 Testing

### Run All Tests

```bash
flutter test
```

### Run a Specific Test File

```bash
flutter test test/rbac_test.dart
flutter test test/blood_request_service_test.dart
flutter test test/local_user_service_test.dart
flutter test test/widget_test.dart
```

### Available Test Suites

| Test File                          | Description                                      |
|------------------------------------|--------------------------------------------------|
| `test/rbac_test.dart`              | Role-based access control & permission validation |
| `test/blood_request_service_test.dart` | Blood request creation, response, filtering   |
| `test/local_user_service_test.dart`| User registration, login, profile updates         |
| `test/widget_test.dart`            | Basic widget smoke test                           |

### Run Tests with Verbose Output

```bash
flutter test --reporter expanded
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

Coverage report will be generated at `coverage/lcov.info`.

---

## 🔑 Demo Accounts

The app uses **local data services** (no backend needed). Demo data is seeded automatically.

| Name            | Phone           | Role     | Verification Status |
|-----------------|-----------------|----------|---------------------|
| John Donor      | +919876543210   | Donor    | Verified            |
| Jane Receiver   | +919876543211   | Receiver | Pending             |
| Bob Smith       | +919876543212   | Donor    | Rejected            |
| Alice Verifier  | +919876543213   | Verifier | Verified            |
| Admin User      | +919876543214   | Admin    | Verified            |

> **Note**: Since this is an MVP with local services, data resets on app restart.

---

## 🔧 Useful Commands

```bash
# Analyze code for lint issues
flutter analyze

# Auto-fix lint issues
dart fix --apply

# Format code
dart format .

# Clean build cache
flutter clean
flutter pub get

# List connected devices
flutter devices
```

---

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/my-feature`
3. **Commit** your changes: `git commit -m "Add my feature"`
4. **Push** to the branch: `git push origin feature/my-feature`
5. **Open** a Pull Request

---

## 📄 License

This project is for educational and demonstration purposes.

---

<p align="center">
  Made with ❤️ and Flutter
</p>
