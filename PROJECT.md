# GTTP India - Trust Administrator Mobile App

## Project Overview
GTTP India is a professional management platform for Trust Administrators to monitor school networks, review flagged reports, and manage educational activities across branches.

**Problem Statement:** Administrators need a secure, real-time dashboard to oversee complex school networks and handle sensitive activity overrides.
**Target Users:** Trust Administrators (Android & iOS).
**Key Goals:** 
- Seamless school oversight.
- Secure report management.
- Data-driven decision making via analytics.

---

## Roadmap

### Phase 1: Discovery & Planning ✅
- [x] Requirement Analysis
- [x] Tech Stack Selection (Riverpod, GoRouter, Dio, Clean Architecture)
- [x] Folder Structure Design

### Phase 2: Project Setup & Configuration ✅
- [x] Flutter project initialization
- [x] Theme & Design System (Material 3)
- [x] Basic Flavors & Env setup

### Phase 3: Authentication & Security (In Progress) 🟡
- [x] Login Form UI
- [x] Auth Repository & Datasource
- [x] JWT Handling with Secure Storage
- [ ] Biometric Support
- [-] Credential Verification (Issue: Provided credentials returning 401)

### Phase 4: Core Features Development (Next) 🚀
- [ ] **Flagged Reports Review**: Overview & Detail override screens.
- [ ] **School Network**: Directory list & individual school stats.
- [ ] **Data Export**: Analytics downloads.
- [ ] **Gallery**: Activity feed visualization.

### Phase 5: Testing (Mandatory) 🧪
- [ ] Unit Tests for domain logic.
- [ ] Widget Tests for UI components.
- [ ] Integration Tests for Auth & Core flows.

---

## Tech Stack
- **Architecture**: Feature-First + Clean Architecture
- **State Management**: Riverpod 2.6
- **Routing**: GoRouter
- **HTTP Client**: Dio + Interceptors
- **LocalStorage**: Flutter Secure Storage (Tokens), Isar (Cache)
- **UI**: Material 3 + Custom Glassmorphism Theme
