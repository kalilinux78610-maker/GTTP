# GTTP Mobile App - Design Brief & Requirements for UI/UX Designer

This document outlines the outstanding design specifications, screens, states, and creative assets needed from the UI/UX design team to complete the development of the **GTTP India Trust Administrator Mobile App**.

---

## 1. Primary Design Identity & Theme Alignment
We have implemented the official color system in the codebase based on the Figma guidelines:
*   **Primary Brand Blue:** `#0066FF` (Main action / Brand color)
*   **Deep Navy:** `#001A33` (Scaffold background base, dark accents)
*   **Saffron Orange:** `#F97316` (Indian Tricolour accent / Call-to-Action buttons)
*   **Tech Cyan:** `#06B6D4` (Future tech & secondary details)
*   **Typography:** Google Fonts Inter

### ⚠️ Critical Gaps Needed:
*   **Dark Mode Specifications:** Exact color mappings for cards, modals, glassmorphism layers, and typography contrast in Dark Mode.
*   **Glassmorphism Specs:** Standardize the glassmorphic card guidelines (blur radius, background opacity, border stroke gradient, and shadow offset).
*   **Tablet/Responsive Designs:** The admin app will be heavily used on tablets (iPads/Android tablets). We need responsive layout grids for dashboards and analytics spreadsheets.

---

## 2. Missing & Under-Construction Screens (Mockups Required)
The backend APIs for these modules exist, but the mobile front-end cannot be fully completed without visual layout and UX guidelines.

| Feature Module | Current Code State | What is Needed from the Designer |
| :--- | :--- | :--- |
| **Students Module** | ❌ Not Started | • Student Directory List UI (search, branch filters)<br>• Student Profile Details View (personal info, academic performance, status chips)<br>• Parent/Guardian contact action layouts |
| **Academic Content** | ❌ Not Started | • Subjects Selection Screen<br>• Syllabus details list (collapsible accordion/tabs)<br>• Timetable weekly/daily calendar grid view |
| **Schedules Management** | ❌ Not Started | • Trust-wide interactive calendar interface<br>• Scheduling modal/form (adding school-level event, deadline, holiday) |
| **Flagged Reports Review** | 🚧 Placeholder / Coming Soon | • Detail layout of a flagged student report<br>• Interactive modal/dialog design for **Override & Approve** (with reason input field)<br>• Rejection/Escalation popup UI |
| **Schools & Classes** | 🚧 Basic List Only | • Classroom directory within a school (students per grade)<br>• Interface for assigning/re-assigning Trust Coordinators to specific schools |

---

## 3. Creative Asset Deliverables Checklist
Please export these assets in **SVG (vector)** or high-resolution **PNG (3x/4x)** format:

### 🖼️ Empty State Illustrations
We want to keep the UX delightful and premium. We need custom, clean illustrations (following the brand color palette) for these empty/error states:
1.  **`empty_reports.svg`** – Displayed when there are no flagged or pending reports to review.
2.  **`empty_search.svg`** – Displayed when search queries return zero results.
3.  **`empty_notifications.svg`** – Displayed when notices/announcements feed is clear.
4.  **`offline_state.svg`** – Displayed when the administrator loses network connectivity.
5.  **`no_certificates.svg`** – Displayed when a user does not have any certificates to download yet.

### 🌀 Lottie Animation Files (JSON)
Micro-animations elevate the app into a premium, state-of-the-art product. Please provide Lottie animations for:
*   **`success_checkmark.json`** – Triggered upon successfully resolving/overriding a flagged report or changing a password.
*   **`data_export_loader.json`** – A premium exporting/downloading progress animation triggered when downloading Excel/PDF data sheets.
*   **`biometric_prompt.json`** – Visual scanner loop (Face ID / Fingerprint fingerprint waves) for secure biometric authentication.

### 📱 App Icons & Splash Screens
*   **Adaptive App Icon Assets:** Foreground and background layers formatted correctly for Android adaptive icons (`108dp x 108dp` overall, safe zone `72dp`) and iOS App Store icons.
*   **Brand Splash screen layout:** Elegant splash layout using the brand mark with a high-end, uncluttered appearance.

---

## 4. Input Fields & Form States Specs
Please provide interactive states (Default, Hover, Focused, Filled, Error, Disabled) for:
*   Standard input fields with floating labels or pre-filled placeholders.
*   Secure PIN code/OTP input boxes (6-digit format with automated focus transitions).
*   Password strength validator checklists (uppercase, numbers, characters).
