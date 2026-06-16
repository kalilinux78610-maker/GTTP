# 🔴 GTTP App — Broken & Pending APIs (Detailed Report for Backend Team)

> **Base URL:** `https://gttp.efsouls.com/api`  
> **Auth:** All endpoints require `Authorization: Bearer <accessToken>`  
> **Date:** 2026-06-16  
> **From:** Flutter Frontend Team → Backend Development Team

---

## Summary: 4 APIs are Broken or Missing

| # | Endpoint | Problem | Impact | Priority |
|---|---|---|---|---|
| 1 | `GET /faculty/courses/{courseId}/students` | **Returns 404** | Faculty cannot see enrolled students | 🔴 Critical |
| 2 | `GET /admin/submissions/pending` | **Returns 404** | Coordinator cannot see pending tasks | 🔴 Critical |
| 3 | `POST /courses/{courseId}/modules/{moduleId}/complete` | **Not verified / may not exist** | Module completion after video watch fails silently | 🟡 High |
| 4 | MCQ Questions in `GET /courses/{id}` | **Returns empty array** `mcq_questions: []` | Quiz screen shows dummy data | 🟡 High |

---

## 🔴 API #1: Get Enrolled Students for a Course (Faculty View)

### Current Problem
When a Faculty member opens a course detail page, the app calls this API to display enrolled students with their progress. **The backend returns HTTP 404 Not Found.**

The app currently shows **mock/dummy student data** as a fallback so the UI doesn't break.

### Endpoint Specification

```
GET /api/faculty/courses/{courseId}/students
```

### Headers
```
Authorization: Bearer <accessToken>
Content-Type: application/json
```

### Path Parameters
| Parameter | Type | Required | Description |
|---|---|---|---|
| `courseId` | string | ✅ Yes | The ID of the course |

### Expected Response — `200 OK`

```json
{
  "status": true,
  "message": "Students fetched successfully",
  "data": [
    {
      "id": "101",
      "student_id": "101",
      "name": "Aarav Sharma",
      "roll_no": "CS-2024-001",
      "class": "10th-A",
      "progress_percent": 75,
      "email": "aarav@school.com",
      "enrolled_at": "2026-01-15T10:00:00Z"
    },
    {
      "id": "102",
      "student_id": "102",
      "name": "Priya Patel",
      "roll_no": "CS-2024-002",
      "class": "10th-A",
      "progress_percent": 40,
      "email": "priya@school.com",
      "enrolled_at": "2026-01-16T11:30:00Z"
    }
  ]
}
```

### Fields the App Reads (Important!)

| Field | Type | Required? | How the App Uses It |
|---|---|---|---|
| `id` or `student_id` | string | ✅ Yes | Used to navigate to Student Progress screen |
| `name` | string | ✅ Yes | Displayed as student name. Also used to generate avatar initials (e.g., "AS" from "Aarav Sharma") |
| `roll_no` | string | ✅ Yes | Shown as "Roll: CS-2024-001" |
| `class` | string | ✅ Yes | Shown as "Class: 10th-A" |
| `progress_percent` | integer (0-100) | ✅ Yes | Shows colored progress badge: Green ≥75%, Orange ≥50%, Red <50% |

### Error Responses Expected
```json
// 401 Unauthorized
{ "status": false, "message": "Invalid or expired token" }

// 403 Forbidden (not a faculty for this course)
{ "status": false, "message": "You are not authorized to view students for this course" }

// 404 Not Found (course doesn't exist)
{ "status": false, "message": "Course not found" }
```

### Where This is Used in the App
- **File:** `teacher_course_details_screen.dart` → `_EnrolledStudentsSection` widget
- **Provider:** `courseEnrolledStudentsProvider(courseId)`
- **Datasource call:** `CoursesRemoteDataSource.getCourseEnrolledStudents(id)`

---

## 🔴 API #2: Get Pending Submissions for a Course (Coordinator/Admin View)

### Current Problem
When a Coordinator opens a course and clicks "Review Now" to see pending student submissions, the app calls this API. **The backend returns HTTP 404 Not Found.**

The `PendingSubmissionsScreen` shows an error message because there's no data.

### Endpoint Specification

```
GET /api/admin/submissions/pending?courseId={courseId}
```

### Headers
```
Authorization: Bearer <accessToken>
Content-Type: application/json
```

### Query Parameters
| Parameter | Type | Required | Description |
|---|---|---|---|
| `courseId` | string | ✅ Yes | Filter submissions for a specific course |

### Expected Response — `200 OK`

```json
{
  "status": true,
  "message": "Pending submissions fetched successfully",
  "data": [
    {
      "id": "sub_001",
      "submission_id": "sub_001",
      "student_name": "Aarav Sharma",
      "roll_no": "CS-2024-001",
      "class": "10th-A",
      "module_name": "Module 1 — Introduction to GTTP",
      "module_id": "mod_1",
      "requirement_title": "Submit Field Visit Report",
      "status": "pending_review",
      "submitted_at": "2026-06-10T10:30:00Z",
      "file_url": "https://storage.example.com/uploads/aarav_report.pdf",
      "notes": "I visited the textile factory and documented my observations."
    },
    {
      "id": "sub_002",
      "submission_id": "sub_002",
      "student_name": "Priya Patel",
      "roll_no": "CS-2024-002",
      "class": "10th-A",
      "module_name": "Module 2 — Practical Assessment",
      "module_id": "mod_2",
      "requirement_title": "Upload Assignment PDF",
      "status": "pending_review",
      "submitted_at": "2026-06-11T14:00:00Z",
      "file_url": "https://storage.example.com/uploads/priya_assignment.pdf",
      "notes": "Completed all 5 practical exercises."
    }
  ]
}
```

### Fields the App Reads (Important!)

| Field | Type | Required? | How the App Uses It |
|---|---|---|---|
| `submission_id` or `id` | string | ✅ Yes | Used as unique key and for navigation to review screen |
| `student_name` | string | ✅ Yes | Displayed in the pending list and review screen |
| `module_name` | string | ✅ Yes | Shown as task title |
| `submitted_at` | string (ISO 8601) | ❌ Optional | Displayed as submission date |
| `file_url` | string (URL) | ❌ Optional | "Open Submitted File" button — opens this URL in browser |
| `notes` | string | ❌ Optional | Shown in review screen as student's notes |
| `status` | string | ✅ Yes | Expected: `"pending_review"` for this endpoint |
| `roll_no` | string | ❌ Optional | Displayed in student info |
| `class` | string | ❌ Optional | Displayed in student info |

### Related: Review Submission API (Already Working ✅)

After viewing a pending submission, the reviewer clicks **Approve** or **Reject**, which calls:

```
POST /api/admin/submissions/{submissionId}/review
```
```json
// Request Body
{
  "status": "approved",       // or "rejected"
  "feedback": "Good work!"    // reviewer's comment
}

// Response
{ "status": true, "message": "Submission reviewed successfully" }
```

> ⚠️ **This API is already working.** The only missing piece is the `GET` endpoint to LIST pending submissions.

### Where This is Used in the App
- **File:** `pending_submissions_screen.dart` → Full list of pending items
- **File:** `assignment_review_screen.dart` → Individual submission review (Approve/Reject)
- **Provider:** `coursePendingSubmissionsProvider(courseId)`
- **Datasource call:** `CoursesRemoteDataSource.getPendingSubmissions(courseId)`

---

## 🟡 API #3: Mark Module as Complete (Student View)

### Current Problem
When a student finishes watching a video in a course module, the app silently calls this API in the background to mark the module as completed. **It's unknown whether this endpoint exists** — the app catches the error silently so it doesn't crash, but the progress may not be updating on the backend.

### Endpoint Specification

```
POST /api/courses/{courseId}/modules/{moduleId}/complete
```

### Headers
```
Authorization: Bearer <accessToken>
Content-Type: application/json
```

### Path Parameters
| Parameter | Type | Required | Description |
|---|---|---|---|
| `courseId` | string | ✅ Yes | Course ID |
| `moduleId` | string | ✅ Yes | Module ID |

### Request Body
```json
// Empty body — the authenticated student's identity comes from the JWT token
{}
```

### Expected Response — `200 OK`
```json
{
  "status": true,
  "message": "Module marked as complete",
  "data": {
    "module_id": "mod_1",
    "is_completed": true,
    "course_progress_percent": 33
  }
}
```

### Expected Behavior
1. Backend should identify the student from the JWT token.
2. Mark this specific module as completed for this student.
3. Recalculate the overall `progress_percent` for this course.
4. If ALL modules are completed → mark the course as completed.
5. **Idempotent**: Calling this multiple times should not cause errors. If already complete, just return success.

### Where This is Used in the App
- **File:** `course_module_detail_screen.dart` → Line 317-319
- **Triggered by:** Video player `onVideoCompleted` callback
- **Datasource call:** `CoursesRemoteDataSource.markModuleComplete(courseId, moduleId)`
- **Error handling:** `.catchError((_) {})` — fails silently, does not crash the app

---

## 🟡 API #4: MCQ Quiz Questions (Inside Course Details Response)

### Current Problem
The `GET /api/courses/{id}` endpoint already returns module data with an `mcq_questions` field, but **it always returns an empty array `[]`**. The app falls back to hardcoded dummy questions for testing.

### What Needs to Change
The `GET /api/courses/{id}` response already has the correct structure. The backend just needs to **populate the `mcq_questions` array** with real data.

### Current Response (Broken)
```json
{
  "data": {
    "id": "1",
    "title": "Course Name",
    "modules": [
      {
        "id": "mod_1",
        "title": "Module 1",
        "mcq_enabled": true,
        "mcq_questions": []     // ← EMPTY! Should have questions
      }
    ]
  }
}
```

### Expected Response (Fixed)
```json
{
  "data": {
    "id": "1",
    "title": "Course Name",
    "modules": [
      {
        "id": "mod_1",
        "title": "Module 1",
        "mcq_enabled": true,
        "mcq_questions": [
          {
            "id": "q1",
            "module_id": "mod_1",
            "question_text": "What is the full form of GTTP?",
            "question_image": null,
            "explanation": "GTTP stands for...",
            "points": 10,
            "order": 1,
            "options": [
              {
                "id": "opt_1",
                "question_id": "q1",
                "option_text": "Global Travel & Tourism Programme",
                "is_correct": true,
                "order": 1
              },
              {
                "id": "opt_2",
                "question_id": "q1",
                "option_text": "General Technical Training Programme",
                "is_correct": false,
                "order": 2
              },
              {
                "id": "opt_3",
                "question_id": "q1",
                "option_text": "Government Teacher Training Platform",
                "is_correct": false,
                "order": 3
              },
              {
                "id": "opt_4",
                "question_id": "q1",
                "option_text": "None of the above",
                "is_correct": false,
                "order": 4
              }
            ]
          }
        ]
      }
    ]
  }
}
```

### MCQ Question Fields the App Reads

| Field | Type | Required? | Description |
|---|---|---|---|
| `id` | string | ✅ Yes | Unique question ID |
| `module_id` | string | ✅ Yes | Parent module ID |
| `question_text` | string | ✅ Yes | The question displayed to the student |
| `question_image` | string (URL) | ❌ Optional | Image shown alongside the question |
| `explanation` | string | ❌ Optional | Shown after quiz is submitted (answer explanation) |
| `points` | integer | ✅ Yes | Points awarded for correct answer |
| `order` | integer | ❌ Optional | Display order (sorted ascending) |

### MCQ Option Fields the App Reads

| Field | Type | Required? | Description |
|---|---|---|---|
| `id` | string | ✅ Yes | Unique option ID |
| `question_id` | string | ✅ Yes | Parent question ID |
| `option_text` | string | ✅ Yes | The option text shown to the student |
| `is_correct` | boolean | ✅ Yes | `true` for the correct answer, `false` for wrong ones |
| `order` | integer | ❌ Optional | Display order |

### Related: Submit Quiz Score API (Already Working ✅)

After the student completes the quiz, the app sends:

```
POST /api/courses/{courseId}/modules/{moduleId}/quiz/submit
```
```json
// Request
{
  "score_percentage": 80,
  "passed": true
}

// Response
{ "status": true, "message": "Quiz submitted" }
```

> ⚠️ **This submit API is already working.** The only issue is that questions aren't being returned.

### Where This is Used in the App
- **File:** `course_quiz_screen.dart` → `_CourseQuizScreenState`
- **Model:** `CourseModuleMcqQuestionModel` and `CourseModuleMcqOptionModel` in `course_module_model.dart`
- **Current fallback:** 2 hardcoded dummy questions on Lines 112-139

---

## 📋 Quick Backend Checklist

### For Backend Developer — Copy This Directly

- [ ] **Build** `GET /api/faculty/courses/{courseId}/students` — Return enrolled students with `name`, `roll_no`, `class`, `progress_percent`
- [ ] **Build** `GET /api/admin/submissions/pending?courseId={id}` — Return pending submissions with `student_name`, `module_name`, `file_url`, `submitted_at`
- [ ] **Verify/Build** `POST /api/courses/{courseId}/modules/{moduleId}/complete` — Accept empty body, mark module complete for authenticated student
- [ ] **Populate** `mcq_questions` array in `GET /api/courses/{id}` response — Add questions with `question_text`, `points`, `options[]` with `is_correct` flag

### Database Tables Likely Needed

```
┌─────────────────────────┐
│   course_enrollments    │
├─────────────────────────┤
│ id                      │
│ course_id (FK)          │
│ student_id (FK)         │
│ progress_percent (int)  │
│ enrolled_at (timestamp) │
│ completed_at (nullable) │
└─────────────────────────┘

┌─────────────────────────┐
│  module_completions     │
├─────────────────────────┤
│ id                      │
│ course_id (FK)          │
│ module_id (FK)          │
│ student_id (FK)         │
│ completed_at (timestamp)│
└─────────────────────────┘

┌─────────────────────────┐
│     mcq_questions       │
├─────────────────────────┤
│ id                      │
│ module_id (FK)          │
│ question_text (text)    │
│ question_image (URL)    │
│ explanation (text)      │
│ points (int, default 10)│
│ order (int)             │
└─────────────────────────┘

┌─────────────────────────┐
│     mcq_options         │
├─────────────────────────┤
│ id                      │
│ question_id (FK)        │
│ option_text (text)      │
│ is_correct (boolean)    │
│ order (int)             │
└─────────────────────────┘

┌─────────────────────────┐
│  student_submissions    │
├─────────────────────────┤
│ id / submission_id      │
│ student_id (FK)         │
│ course_id (FK)          │
│ module_id (FK)          │
│ file_url (URL)          │
│ notes (text)            │
│ status (enum)           │  ← pending_review | approved | rejected
│ feedback (text)         │  ← reviewer's comment
│ submitted_at (timestamp)│
│ reviewed_at (nullable)  │
│ reviewed_by (FK)        │
└─────────────────────────┘
```

---

*Generated from codebase analysis on 2026-06-16. Share this document directly with your backend developer.*
