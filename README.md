# GTTP Mobile Application

Welcome to the GTTP Mobile Application repository. This project is a robust, production-grade Flutter application built for educational and networking management.

## 🌟 Key Features
- **Role-Based Access:** Secure login via Email/OTP.
- **Course Management:** View enrolled courses, explore modules, take quizzes, and submit assignment reports.
- **Notices & Announcements:** Real-time updates and important alerts.
- **School Network & Gallery:** Connect with peers and view event galleries.
- **Robust Architecture:** Feature-First Clean Architecture ensures a scalable, maintainable, and testable codebase.

## 🏗️ Architecture & Tech Stack
- **Framework:** Flutter (Material 3)
- **State Management:** Riverpod (v2.0+)
- **Routing:** GoRouter
- **Networking:** Dio (with interceptors for secure token handling)
- **Security:** `flutter_secure_storage`, `flutter_dotenv`
- **Testing:** Integration Testing (`integration_test`), Mocktail

### Folder Structure (Feature-First)
```
lib/
├── core/               # App-wide configs, networking, routing, themes
├── features/           # Independent feature modules
│   ├── auth/           
│   ├── courses/        
│   ├── dashboard/      
│   ├── notices/        
│   └── profile/        
└── main.dart           # App Entry Point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable recommended)
- Dart SDK
- Android Studio / Xcode (for emulation)

### Setup Instructions
1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd GTTP
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Environment Configuration:**
   Create a `.env` file in the root directory:
   ```env
   API_BASE_URL=https://gttp.efsouls.com/api
   ```

4. **Run the App:**
   ```bash
   flutter run
   ```

## 🧪 Testing
The project includes a robust suite of native Integration Tests verifying the entire user flow (Login -> OTP -> Dashboard -> Courses).
Run the E2E tests via:
```bash
flutter test integration_test/app_test.dart
```

## 🛡️ Security Best Practices Enforced
- **Zero Hardcoded Secrets:** All sensitive endpoints use `.env`.
- **Encrypted Storage:** Auth tokens are saved securely via `flutter_secure_storage`.
- **Resilient Networking:** Interceptors automatically manage 401 token states and retry logic.

## 📚 Further Documentation
Please refer to the `docs/handover/` directory for detailed client Handover packages, Setup Guides, and Security Audits.
