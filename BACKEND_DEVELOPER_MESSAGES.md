# 📋 Copy-Paste Messages for Backend Developer

> Copy any message below and send it directly to your backend developer via WhatsApp/Slack/Email.

---

## ✉️ Message 1: Main Overview Message

```
🔴 URGENT: 4 APIs Needed for GTTP Mobile App

Hi! The Flutter app is almost complete but 4 APIs are either returning 404 or missing data. The app is currently showing dummy/mock data as a workaround. Please build these ASAP:

1️⃣ GET /api/faculty/courses/{courseId}/students → Returns 404
2️⃣ GET /api/admin/submissions/pending?courseId={courseId} → Returns 404  
3️⃣ POST /api/courses/{courseId}/modules/{moduleId}/complete → Not verified
4️⃣ mcq_questions in GET /api/courses/{id} → Returns empty array []

All endpoints need Bearer token auth.
Base URL: https://gttp.efsouls.com/api

I'm sending detailed specs for each API separately 👇
```

---

## ✉️ Message 2: API #1 — Enrolled Students

```
📌 API #1: Get Enrolled Students (Faculty View)

Endpoint: GET /api/faculty/courses/{courseId}/students
Auth: Bearer Token (required)
Method: GET

Path Parameters:
- courseId (string, required) — The course ID

Expected Response (200 OK):
{
  "status": true,
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
    }
  ]
}

Required Fields (app will crash without these):
✅ id or student_id (string) — unique student ID
✅ name (string) — full name
✅ roll_no (string) — roll number
✅ class (string) — class name
✅ progress_percent (integer, 0-100) — course completion %

Optional Fields:
- email (string)
- enrolled_at (ISO 8601 datetime)

Error Responses:
- 401: { "status": false, "message": "Unauthorized" }
- 404: { "status": false, "message": "Course not found" }

Database: You'll need a course_enrollments table with columns:
- id, course_id (FK), student_id (FK), progress_percent (int), enrolled_at (timestamp)

Current Status: Returns 404. App shows mock data as fallback.
```

---

## ✉️ Message 3: API #2 — Pending Submissions

```
📌 API #2: Get Pending Submissions (Coordinator/Admin View)

Endpoint: GET /api/admin/submissions/pending?courseId={courseId}
Auth: Bearer Token (required)
Method: GET

Query Parameters:
- courseId (string, required) — filter by course

Expected Response (200 OK):
{
  "status": true,
  "data": [
    {
      "id": "sub_001",
      "submission_id": "sub_001",
      "student_name": "Aarav Sharma",
      "roll_no": "CS-2024-001",
      "class": "10th-A",
      "module_name": "Module 1 — Introduction",
      "module_id": "mod_1",
      "requirement_title": "Submit Field Visit Report",
      "status": "pending_review",
      "submitted_at": "2026-06-10T10:30:00Z",
      "file_url": "https://storage.example.com/uploads/report.pdf",
      "notes": "Student's notes about their submission"
    }
  ]
}

Required Fields:
✅ submission_id or id (string) — unique submission ID
✅ student_name (string) — student's full name
✅ module_name (string) — which module this belongs to
✅ status (string) — should be "pending_review"

Optional but Important:
- submitted_at (ISO 8601 datetime)
- file_url (URL string) — the file the student uploaded
- notes (string) — student's notes
- roll_no, class (strings)

NOTE: The review API already works! ✅
POST /api/admin/submissions/{submissionId}/review
Body: { "status": "approved", "feedback": "Good work!" }
We just need the GET endpoint to LIST pending items.

Database: You'll need a student_submissions table with columns:
- id, student_id (FK), course_id (FK), module_id (FK)
- file_url (text), notes (text)  
- status (enum: pending_review | approved | rejected)
- feedback (text), submitted_at, reviewed_at, reviewed_by (FK)

Current Status: Returns 404. App shows error screen.
```

---

## ✉️ Message 4: API #3 — Mark Module Complete

```
📌 API #3: Mark Module as Complete (Student View)

Endpoint: POST /api/courses/{courseId}/modules/{moduleId}/complete
Auth: Bearer Token (required)
Method: POST

Path Parameters:
- courseId (string, required) — course ID
- moduleId (string, required) — module ID

Request Body: Empty {} (student identity comes from JWT token)

Expected Response (200 OK):
{
  "status": true,
  "message": "Module marked as complete",
  "data": {
    "module_id": "mod_1",
    "is_completed": true,
    "course_progress_percent": 33
  }
}

Backend Logic:
1. Get student_id from JWT token
2. Insert into module_completions table (if not already exists)
3. Recalculate course progress_percent for this student
4. If ALL modules completed → mark course as completed
5. Must be IDEMPOTENT — calling twice should NOT error

Database: You'll need a module_completions table:
- id, course_id (FK), module_id (FK), student_id (FK), completed_at (timestamp)
- Add UNIQUE constraint on (course_id, module_id, student_id)

Current Status: Unknown if this endpoint exists. App calls it silently after video completion. Errors are caught and ignored.
```

---

## ✉️ Message 5: API #4 — MCQ Quiz Questions

```
📌 API #4: MCQ Questions in Course Details Response

This is NOT a new endpoint. The existing GET /api/courses/{id} already returns mcq_questions but the array is always empty.

Current Response (broken):
"mcq_questions": []

Expected Response (fixed):
"mcq_questions": [
  {
    "id": "q1",
    "module_id": "mod_1",
    "question_text": "What is the full form of GTTP?",
    "question_image": null,
    "explanation": "GTTP stands for Global Travel & Tourism Programme",
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

Question Required Fields:
✅ id (string)
✅ module_id (string)
✅ question_text (string) — the actual question
✅ points (integer) — marks for correct answer
✅ options (array) — list of answer choices

Option Required Fields:
✅ id (string)
✅ question_id (string)
✅ option_text (string) — the choice text
✅ is_correct (boolean) — true for correct answer

Optional Fields:
- question_image (URL) — image with question
- explanation (string) — shown after quiz submission
- order (integer) — display order

Database Tables Needed:

mcq_questions:
- id, module_id (FK), question_text (text), question_image (URL nullable)
- explanation (text nullable), points (int default 10), order (int)

mcq_options:
- id, question_id (FK), option_text (text), is_correct (boolean), order (int)

NOTE: The quiz SUBMIT API already works! ✅
POST /api/courses/{courseId}/modules/{moduleId}/quiz/submit
Body: { "score_percentage": 80, "passed": true }
We just need the questions to be populated.

Current Status: Returns empty array. App shows 2 dummy questions as fallback.
```

---

## ✉️ Message 6: Complete Database Schema (All Tables)

```
📌 Complete Database Schema for Pending APIs

1️⃣ course_enrollments
   - id (PK)
   - course_id (FK → courses)
   - student_id (FK → users)
   - progress_percent (INT, default 0)
   - enrolled_at (TIMESTAMP)
   - completed_at (TIMESTAMP, nullable)
   UNIQUE(course_id, student_id)

2️⃣ module_completions
   - id (PK)
   - course_id (FK → courses)
   - module_id (FK → course_modules)
   - student_id (FK → users)
   - completed_at (TIMESTAMP)
   UNIQUE(course_id, module_id, student_id)

3️⃣ student_submissions
   - id (PK)
   - student_id (FK → users)
   - course_id (FK → courses)
   - module_id (FK → course_modules)
   - requirement_title (VARCHAR)
   - file_url (TEXT, nullable)
   - notes (TEXT, nullable)
   - status (ENUM: pending_review, approved, rejected)
   - feedback (TEXT, nullable)
   - submitted_at (TIMESTAMP)
   - reviewed_at (TIMESTAMP, nullable)
   - reviewed_by (FK → users, nullable)

4️⃣ mcq_questions
   - id (PK)
   - module_id (FK → course_modules)
   - question_text (TEXT)
   - question_image (VARCHAR, nullable)
   - explanation (TEXT, nullable)
   - points (INT, default 10)
   - order (INT, default 0)

5️⃣ mcq_options
   - id (PK)
   - question_id (FK → mcq_questions)
   - option_text (TEXT)
   - is_correct (BOOLEAN, default false)
   - order (INT, default 0)

All tables should have created_at and updated_at timestamps.
```

---

## ✉️ Message 7: Quick Summary Checklist

```
✅ Backend API Checklist for GTTP App

☐ Build GET /api/faculty/courses/{courseId}/students
   → Return enrolled students with name, roll_no, class, progress_percent

☐ Build GET /api/admin/submissions/pending?courseId={id}
   → Return pending submissions with student_name, module_name, file_url

☐ Build/Verify POST /api/courses/{courseId}/modules/{moduleId}/complete
   → Empty body, mark module done for JWT user, recalculate progress

☐ Populate mcq_questions in GET /api/courses/{id}
   → Add questions with options, each option has is_correct flag

Already Working (no changes needed):
✅ POST /api/admin/submissions/{id}/review (approve/reject)
✅ POST /api/courses/{courseId}/modules/{moduleId}/quiz/submit
✅ All auth APIs (login, verify-otp, forgot-password, reset-password)
✅ All other 35+ endpoints

Please prioritize #1 and #2 first — those are the most visible broken features.
Let me know once any of these are ready and I'll test from the app! 🚀
```
 
 