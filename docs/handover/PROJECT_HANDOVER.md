# GTTP Mobile App - Project Handover Document

## 1. Project Overview
**Project Name:** GTTP Mobile Application  
**Description:** A professional, robust educational and networking platform enabling students and faculty to access courses, submit assignments, read notices, track academic progress, and manage secure profiles.  
**Target Platform:** Cross-platform (Android, iOS)  

## 2. Tech Stack
- **Framework:** Flutter (Latest Stable, Dart 3 compatible)
- **Architecture:** Feature-First + Clean Architecture (Data -> Domain -> Presentation)
- **State Management:** Riverpod 2.0+
- **Navigation:** GoRouter for declarative routing and deep linking
- **Networking:** Dio + Interceptors for secure, retry-capable REST API communication
- **Security:** `flutter_secure_storage` for token management; `flutter_dotenv` for environment secrets
- **UI/UX:** Custom Design System conforming to Material 3 principles

## 3. Features Delivered
### MVP Features (Core)
- **Secure Authentication:** Login via Email/Password, OTP verification, and JWT Token management with auto-logout.
- **Dashboard:** Dynamic landing page with quick-access modules.
- **Courses Management:** Browse enrolled courses, view modules, take quizzes, and submit assignment reports.
- **Notices System:** Role-based announcements with unread badges and priority alerts.
- **User Profiles:** View and edit personal profiles and manage account settings.

### Extra Features (Polished)
- **Offline Resilience:** Detection of network loss with graceful degradation (showing cached data flags).
- **Responsive Navigation:** Bottom Navigation with safe-area calculations and keyboard awareness.
- **Automated QA:** Native integration test coverage and AI-compatible QA scenario maps.

## 4. Architecture & Folder Structure
The codebase strictly adheres to a modular Feature-First approach:
```
lib/
├── core/               # Shared utilities, routing, security, themes, networking
├── features/           # Independent feature modules
│   ├── auth/           # Authentication flows and secure token storage
│   ├── courses/        # Course lists, modules, quizzes, submissions
│   ├── dashboard/      # Main hub and quick modules
│   ├── notices/        # System announcements and alerts
│   └── profile/        # User data management
└── main.dart           # App entry point
```

## 5. How to Run the Project (Step-by-step)
*Please refer to `Setup_Guide.md` for comprehensive developer onboarding.*
1. Ensure Flutter SDK is installed.
2. Clone the repository and navigate to the project root.
3. Run `flutter pub get`.
4. Create a `.env` file in the root with your `API_BASE_URL`.
5. Run the app: `flutter run`.

## 6. Environment Variables
To ensure security, secrets are never hardcoded. You must configure a `.env` file in the root:
```env
API_BASE_URL=https://gttp.efsouls.com/api
# Additional keys (e.g. Analytics, Crashlytics) can be added here
```

## 7. Backend Documentation
- **Architecture:** REST API integration.
- **Data Flow:** The application uses the `Dio` client configured in the Data Layer to communicate with the backend. 
- **Security:** All authenticated routes pass a Bearer token. On 401 Unauthorized responses, the app automatically navigates the user back to the login gateway.

## 8. Testing Report
*Please refer to `Testing_Report.md`.*
- Native Flutter Integration Tests execute end-to-end user flows (Login -> OTP -> Dashboard -> Tab Navigation -> Course Detail Extraction).
- 100% pass rate on Windows native runner.

## 9. Security & Performance Audit
*Please refer to `Security_Audit_Summary.md`.*
- **Security:** Zero hardcoded secrets, robust JWT handling, secure token storage.
- **Performance:** Extensive use of `cached_network_image`, layout skeletonizers for smooth perceived loading, and `const` optimizations.

## 10. Deployment Instructions
*(Skipped per request. Project is already in Production Review).*

## 11. Credentials & Access
- **Test Account:** `shreyanshvasava@efsouls.com`
- **Test Password:** `shreyansh1`
- **Test OTP:** `334750`

## 12. User Manual Summary
*Please refer to `User_Manual.md` for client-facing app usage guidelines.*

## 13. Post-Delivery Support Plan
- Monitor crash reports via backend logs or Firebase Crashlytics (if integrated).
- The repository is fully documented to allow any mid/senior-level Flutter developer to take over maintenance immediately.
