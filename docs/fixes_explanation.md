I have investigated both issues. Here is what I found and fixed:

### 1. Quiz Section Failing Correct Answers
**The Issue:** The Flutter app was strictly checking if the selected option was a boolean `true` or an integer `1` (`selectedOption.isCorrect == true || selectedOption.isCorrect == 1`). However, APIs often return these values as strings (e.g., `"1"` or `"true"`). Since Dart is strongly typed, `"1" == 1` evaluates to `false`, causing correct answers to be marked as incorrect.
**The Fix:** I updated the `_submitQuiz` logic in `course_quiz_screen.dart` to robustly handle string values as well:
```dart
if (selectedOption.isCorrect == true || 
    selectedOption.isCorrect == 1 || 
    selectedOption.isCorrect?.toString() == '1' || 
    selectedOption.isCorrect?.toString().toLowerCase() == 'true') {
  score += (question.points as int);
}
```
This is now fixed, and quizzes should calculate scores correctly.

---

### 2. Dashboard Showing 3 Students vs. My Students List Showing 2
I ran several diagnostic scripts on the backend and checked the client-side filtering logic. There are a few reasons why this discrepancy happens:

1. **Dashboard Caching (Most Likely):** 
   The `DashboardController` caches the dashboard statistics for **5 minutes** to improve performance (`Cache::remember("dashboard_{$scope}", ...)`). However, the "My Students" list (`StudentController::index`) always fetches live data. If a student was recently deleted, deactivated, or moved to another school, the Dashboard will still show `3` for a few minutes until the cache expires, while the list accurately shows `2`.

2. **Inactive Students:**
   The `DashboardController` counts *all* students for a school (`Student::where('school_id', $schoolId)->count()`). However, the "My Students" list strictly filters out inactive students (`->where('is_active', true)`). If one of the 3 students was marked as inactive, they will appear in the Dashboard count but not in the list.

3. **Dummy/Test Account Filter:**
   The Flutter app has a built-in filter in `GttpRemoteDataSource` that automatically hides any student whose name is "dummy", "test", "mock", or whose email is "test@test.com". The Dashboard does not filter these out. If you created a student with a test name, they will be counted on the Dashboard but hidden from the UI list.

**How to verify:** 
Try pulling down to refresh on the "My Students" screen. If the Dashboard still shows 3 after 5 minutes, it means one of the students in that school is either marked as `is_active = false` or has a name like "test" which the mobile app hides intentionally. 

Do you want me to update the `DashboardController` so that it also filters out inactive students and matches the list exactly?
