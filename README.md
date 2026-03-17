# 🩸 BloodDonate

A Flutter-based Blood Donation app that connects **donors**, **receivers**, **verifiers**, and **admins** — with Firebase authentication, PostgreSQL database (via Firebase Data Connect), role-based access control, identity verification, and a clean feature-driven architecture.

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Firebase Setup](#-firebase-setup)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Local Installation](#-local-installation)
- [Running the App](#-running-the-app)
- [Testing](#-testing)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

- **Firebase Authentication** — Phone OTP verification
- **Role-Based Access Control (RBAC)** — Donor, Receiver, Verifier, Admin, SuperAdmin roles
- **Identity Verification** — Upload ID documents, selfie, and medical docs
- **Blood Requests** — Post, browse, filter, and respond to blood donation requests
- **Real-time Updates** — Firestore/Data Connect for live data sync
- **Role-Specific Dashboards** — Tailored dashboard for each user role
- **Push Notifications** — Firebase Cloud Messaging
- **Profile Management** — Edit profile, blood type, availability status
- **Admin Panel** — User management, verification queue, banning, stats
- **Dark & Light Theme** — System-adaptive theming

---

## 🛠 Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.x |
| Language | Dart (SDK ^3.11.0) |
| State Management | Riverpod (`flutter_riverpod`) |
| Navigation | GoRouter (`go_router`) |
| Authentication | Firebase Auth (Phone OTP) |
| Database | Firebase Data Connect (PostgreSQL) / Firestore (NoSQL) |
| Storage | Firebase Storage |
| Notifications | Firebase Cloud Messaging |
| Local Storage | Hive, Flutter Secure Storage |
| Animations | Lottie, Shimmer |
| Camera & Images | camera, image_picker, image_cropper |
| Code Generation | Freezed, json_serializable |

---

## 🔥 Firebase Setup

### Quick Start (New Laptop)

```bash
# 1. Clone the project
git clone <your-repo>
cd blood_donate

# 2. Install dependencies
flutter pub get

# 3. Install Firebase CLI
npm install -g firebase-tools

# 4. Login to Firebase
firebase login

# 5. Initialize Data Connect (if not done)
firebase init dataconnect
# Select "Use existing Cloud SQL instance" if prompted

# 6. Deploy and generate SDK
firebase deploy
```

### Firebase Project Details

| Resource | Details |
|----------|---------|
| Project ID | `blood-bank-8cc48` |
| Database | Cloud SQL (PostgreSQL) via Data Connect |
| Auth | Phone OTP |
| Storage | Firebase Storage |

### For Detailed Setup Instructions

See [FIREBASE_SETUP.md](./FIREBASE_SETUP.md)

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point (Firebase init)
├── core/                        # App-wide core utilities
│   ├── constants/               # Colors, spacing, typography
│   ├── errors/                 # Custom failure classes
│   ├── router/                 # GoRouter configuration
│   └── theme/                  # Light & dark theme definitions
├── features/                   # Feature modules (clean architecture)
│   ├── auth/                   # Authentication (login, register, OTP)
│   ├── blood_requests/         # Blood request CRUD operations
│   ├── dashboard/              # Role-specific dashboards
│   ├── notifications/          # In-app notifications
│   ├── profile/                # Profile view & edit
│   └── verification/           # Document upload & verification review
├── rbac/                       # Role-based access control
│   ├── models/                 # AppRole, AppPermission enums
│   ├── permission_guard.dart   # Route/action permission guards
│   ├── rbac_service.dart      # RBAC service logic
│   └── role_permission_matrix.dart
└── shared/                     # Shared across features
    ├── services/               # Firebase & data services
    │   ├── firebase_auth_service.dart
    │   ├── firestore_service.dart
    │   ├── data_connect_service.dart
    │   └── user_model.dart
    └── widgets/                # Reusable widgets

firebase/
├── dataconnect.yaml            # Data Connect config
├── schema.gql                  # PostgreSQL schema
└── connectors/                # GraphQL queries & mutations
    ├── users.gql
    ├── blood_requests.gql
    ├── verifications.gql
    └── notifications.gql
```

---

## 📦 Prerequisites

### 1. Flutter SDK

Install Flutter **3.x** (requires Dart SDK ^3.11.0):

```bash
flutter --version
```

### 2. Node.js & npm

Required for Firebase CLI:

```bash
node --version
npm --version
```

### 3. Android Setup

- **Android Studio** (latest)
- **Android SDK** (API 34 or higher)
- **Android Emulator** or physical device with USB debugging

```bash
flutter doctor --android-licenses
flutter doctor
```

### 4. Firebase CLI

```bash
npm install -g firebase-tools
firebase --version
```

---

## 🚀 Local Installation

### Step 1: Clone the Repository

```bash
git clone <your-repo>
cd blood_donate
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Configure Firebase

The project includes:
- `android/app/google-services.json` — Android Firebase config

### Step 4: Run the App

```bash
flutter run
```

---

## ▶️ Running the App

### On Android Emulator

```bash
flutter devices
flutter run
```

### On Physical Device

1. Enable **Developer Options** → **USB Debugging**
2. Connect via USB
3. Run: `flutter run`

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/`

---

## 🧪 Testing

### Run All Tests

```bash
flutter test
```

### Run Specific Tests

```bash
flutter test test/rbac_test.dart
flutter test test/blood_request_service_test.dart
flutter test test/local_user_service_test.dart
```

### Analyze Code

```bash
flutter analyze
```

---

## 📂 Important Files

| File | Description |
|------|-------------|
| `FIREBASE_SETUP.md` | Complete Firebase/Data Connect setup guide |
| `lib/main.dart` | App entry with Firebase initialization |
| `lib/shared/services/firebase_auth_service.dart` | Phone OTP authentication |
| `lib/shared/services/firestore_service.dart` | Firestore database operations |
| `lib/shared/services/data_connect_service.dart` | Data Connect (PostgreSQL) wrapper |
| `firebase/schema.gql` | PostgreSQL database schema |
| `android/app/google-services.json` | Firebase Android config |

---

## 🔧 Useful Commands

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Code analysis
flutter analyze
dart fix --apply
dart format .

# Build
flutter build apk --debug
flutter build apk --release

# Firebase
firebase login
firebase deploy
firebase init dataconnect
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

## 🔗 Links

- [Firebase Console](https://console.firebase.google.com/project/blood-bank-8cc48)
- [Firebase Data Connect Docs](https://firebase.google.com/docs/data-connect)
- [Flutter Docs](https://docs.flutter.dev)

---

<p align="center">
  Made with ❤️ and Flutter
</p>
