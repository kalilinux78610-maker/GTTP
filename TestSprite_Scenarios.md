# TestSprite E2E Scenarios for GTTP App

This document contains plain-English test scenarios intended to guide the TestSprite autonomous QA agent in understanding the critical flows of the GTTP application.

## 1. Authentication Scenarios

### Scenario 1.1: Valid Login Flow
**Description:** Verify that a user can successfully log into the dashboard.
**Steps:**
1. Open the app and ensure the "Login to your account" screen is visible.
2. Locate the "Email Address" field and input `shreyanshvasava@efsouls.com`.
3. Locate the "Password" field and input `shreyansh1`.
4. Tap the **Login** button.
5. **Expected Result:** The app navigates to the "Verify OTP" screen.
6. Locate the 6 OTP input boxes and enter the code `334750`.
7. Tap the **Verify OTP** button.
8. **Expected Result:** The app navigates to the `/dashboard` route, and the main dashboard UI (e.g., welcome text, bottom navigation bar) is displayed.

### Scenario 1.2: Invalid Login Handling
**Description:** Verify that entering invalid credentials shows the appropriate error dialog.
**Steps:**
1. Open the app to the Login screen.
2. Input `invalid@example.com` for Email and `wrongpassword` for Password.
3. Tap the **Login** button.
4. **Expected Result:** A modal dialog appears containing the text "Login Failed" and an error message.

## 2. Dashboard & Home Scenarios

### Scenario 2.1: Verify Main Dashboard Elements
**Description:** Ensure the Dashboard loads core components.
**Steps:**
1. Complete Scenario 1.1 to log in.
2. **Expected Result:** The Home Dashboard is visible.
3. Verify that quick-access modules like "Certificates", "Gallery", or "Events" are visible on the dashboard grid.

### Scenario 2.2: Navigate to Gallery
**Description:** Check that the Gallery loads images.
**Steps:**
1. From the Dashboard, locate and tap the "Gallery" menu item.
2. **Expected Result:** The Gallery screen loads and displays a grid of images.
3. Tap the "Back" button to return to the Dashboard.

## 3. Notices Scenarios

### Scenario 3.1: View Notices List
**Description:** Ensure that system notices load correctly.
**Steps:**
1. Log into the app.
2. Tap the **Notices** tab on the bottom navigation bar.
3. **Expected Result:** A list of recent notices/announcements is displayed.

### Scenario 3.2: Read a Notice
**Description:** Ensure notice details can be opened.
**Steps:**
1. Navigate to the Notices tab.
2. Tap on the first notice in the list.
3. **Expected Result:** The Notice Details screen opens showing the full title and description.

## 4. Courses Scenarios

### Scenario 4.1: View Enrolled Courses
**Description:** Verify the courses screen populates.
**Steps:**
1. Log into the app.
2. Tap the **Courses** tab on the bottom navigation bar.
3. **Expected Result:** The app displays a list of courses the user is enrolled in.

### Scenario 4.2: Open Course Details
**Description:** Verify course modules are accessible.
**Steps:**
1. From the Courses tab, tap on any active course card.
2. **Expected Result:** The Course Detail screen loads, showing the syllabus or list of modules for that course.

## 5. Profile Scenarios

### Scenario 5.1: View User Profile
**Description:** Ensure the profile screen displays the user's data.
**Steps:**
1. Log into the app.
2. Tap the **Profile** tab on the bottom navigation bar.
3. **Expected Result:** The user's name, email, and school/details are visible on screen.

### Scenario 5.2: Edit Profile Access
**Description:** Verify the Edit Profile screen can be reached.
**Steps:**
1. From the Profile tab, tap the "Edit Profile" button or icon.
2. **Expected Result:** The Edit Profile screen opens with pre-filled form fields containing the user's data.

## Notes for Automation Agent
- **Navigation:** The app utilizes `go_router` for strict path-based navigation.
- **Loading States:** Many network actions show a `CircularProgressIndicator`. The agent must wait for these indicators to disappear before asserting UI states.
- **Permissions:** Some features (like creating notices or accessing the School Network) depend on the user's role (e.g., student vs. faculty vs. admin).
