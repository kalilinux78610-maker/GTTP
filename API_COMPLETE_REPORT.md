# GTTP App — Complete API Report

> **Base URL:** `https://gttp.efsouls.com/api`  
> **Auth:** Bearer Token (JWT) — sent via `Authorization: Bearer <token>` header  
> **Last Updated:** 2026-06-16

---

## 📊 Summary

| Category | Total APIs | ✅ Working | 🔴 Broken/Missing |
|---|---|---|---|
| Authentication | 5 | 5 | 0 |
| Dashboard | 4 | 4 | 0 |
| Courses | 8 | 5 | 3 |
| Reports | 8 | 8 | 0 |
| Notices | 4 | 4 | 0 |
| Events | 1 | 1 | 0 |
| Certificates | 2 | 2 | 0 |
| School Network | 4 | 4 | 0 |
| General Data | 6 | 6 | 0 |
| **TOTAL** | **42** | **39** | **3** |

---

## 🔐 1. Authentication APIs

| # | Method | Endpoint | Status | Description |
|---|---|---|---|---|
| 1 | `POST` | `/auth/login` | ✅ Working | Login with email + password. Returns `accessToken` or `user_id` for OTP flow. |
| 2 | `POST` | `/auth/verify-otp` | ✅ Working | Verify OTP with `user_id` + `otp`. Returns `accessToken` on success. |
| 3 | `POST` | `/auth/resend-otp` | ✅ Working | Resend OTP. Sends `user_id` as FormData. |
| 4 | `POST` | `/auth/forgot-password` | ✅ Working | Request password reset. Sends `email`. Returns `user_id`. |
| 5 | `POST` | `/auth/reset-password` | ✅ Working | Reset password. Sends `email`, `otp`, `password`, `password_confirmation`. |

### Request/Response Details:

#### `POST /auth/login`
```json
// Request
{ "email": "user@example.com", "password": "password123" }

// Response (OTP required)
{ "user_id": 42, "otp_required": true }

// Response (Direct login)
{ "accessToken": "eyJhbGci...", "refreshToken": "...", "user": { "name": "...", "email": "...", "role": "..." } }
```

#### `POST /auth/verify-otp`
```json
// Request
{ "user_id": 42, "otp": "123456" }

// Response
{ "accessToken": "eyJhbGci...", "refreshToken": "...", "user": { "name": "...", "role": "..." } }
```

#### `POST /auth/resend-otp`
```
// Request (FormData)
user_id: "42"

// Response
{ "status": true, "message": "OTP resent successfully" }
```

#### `POST /auth/forgot-password`
```json
// Request
{ "email": "user@example.com" }

// Response
{ "user_id": 42, "message": "OTP sent to your email" }
```

#### `POST /auth/reset-password`
```json
// Request
{ "email": "user@example.com", "otp": "123456", "password": "newPass123", "password_confirmation": "newPass123" }

// Response
{ "status": true, "message": "Password reset successfully" }
```

---

## 📊 2. Dashboard APIs

| # | Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|---|
| 6 | `GET` | `/dashboard` | ✅ | ✅ Working | Admin/Faculty dashboard stats |
| 7 | `GET` | `/student/dashboard` | ✅ | ✅ Working | Student-specific dashboard |
| 8 | `GET` | `/principal/dashboard` | ✅ | ✅ Working | Principal dashboard stats |
| 9 | `GET` | `/national-coordinator/dashboard` | ✅ | ✅ Working | Coordinator dashboard stats |

### Expected Response Format:
```json
{
  "data": {
    "total_students": 150,
    "total_classes": 5,
    "total_courses": 12,
    "total_users": 20,
    "total_notices": 8,
    "total_schools": 3,
    "total_schedules": 10,
    "total_certificates": 5
  },
  "user": {
    "name": "Admin User",
    "email": "admin@school.com",
    "role": "super_admin"
  }
}
```

---

## 📚 3. Courses APIs

| # | Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|---|
| 10 | `GET` | `/courses` | ✅ | ✅ Working | List all courses |
| 11 | `GET` | `/courses/{id}` | ✅ | ✅ Working | Course details with modules |
| 12 | `POST` | `/courses/{id}/enroll` | ✅ | ✅ Working | Student enrolls in a course |
| 13 | `GET` | `/faculty/courses/{id}/students` | ✅ | 🔴 **Returns 404** | Get enrolled students for faculty view |
| 14 | `GET` | `/admin/submissions/pending?courseId={id}` | ✅ | 🔴 **Returns 404** | Pending submissions for coordinator view |
| 15 | `POST` | `/courses/{courseId}/modules/{moduleId}/quiz/submit` | ✅ | ✅ Working | Submit quiz score |
| 16 | `POST` | `/admin/submissions/{submissionId}/review` | ✅ | ✅ Working | Approve/Reject a submission |
| 17 | `POST` | `/courses/{courseId}/modules/{moduleId}/complete` | ✅ | 🔴 **Not verified** | Mark module as complete |
| 18 | `POST` | `/courses/{courseId}/modules` | ✅ | ✅ Working | Create a new module |

### Request/Response Details:

#### `GET /courses`
```json
// Response
{
  "data": [
    {
      "id": "1",
      "title": "Flutter Development",
      "description": "...",
      "cover_image": "https://...",
      "start_date": "2026-01-01",
      "end_date": "2026-06-30",
      "progress_percent": 65,
      "modules": [...]
    }
  ]
}
```

#### `GET /courses/{id}`
```json
// Response
{
  "data": {
    "id": "1",
    "title": "...",
    "modules": [
      {
        "id": "m1",
        "title": "Introduction",
        "type": "video",
        "type_label": "Video",
        "duration_hours": "2",
        "is_completed": false,
        "mcq_enabled": true,
        "mcq_questions": [
          {
            "id": "q1",
            "module_id": "m1",
            "question_text": "What is Flutter?",
            "explanation": "Flutter is...",
            "points": 10,
            "options": [
              { "id": "o1", "question_id": "q1", "option_text": "A framework", "is_correct": true },
              { "id": "o2", "question_id": "q1", "option_text": "A language", "is_correct": false }
            ]
          }
        ]
      }
    ]
  }
}
```

#### 🔴 `GET /faculty/courses/{id}/students` — NEEDS TO BE BUILT
```json
// Expected Response
{
  "data": [
    {
      "id": "101",
      "student_id": "101",
      "name": "Aarav Sharma",
      "roll_no": "CS-2024-001",
      "class": "10th-A",
      "progress_percent": 75
    }
  ]
}
```

#### 🔴 `GET /admin/submissions/pending?courseId={id}` — NEEDS TO BE BUILT
```json
// Expected Response
{
  "data": [
    {
      "id": "sub_1",
      "submission_id": "sub_1",
      "student_name": "Aarav Sharma",
      "roll_no": "CS-2024-001",
      "class": "10th-A",
      "module_title": "Module 1 - Intro",
      "requirement_title": "Submit Assignment",
      "status": "pending_review",
      "submitted_at": "2026-06-10T10:30:00Z",
      "file_url": "https://storage.example.com/file.pdf"
    }
  ]
}
```

#### `POST /admin/submissions/{submissionId}/review`
```json
// Request
{ "status": "approved", "feedback": "Good work!" }
// OR
{ "status": "rejected", "feedback": "Please resubmit with corrections." }

// Response
{ "status": true, "message": "Submission reviewed successfully" }
```

#### `POST /courses/{courseId}/modules/{moduleId}/quiz/submit`
```json
// Request
{ "score_percentage": 80, "passed": true }

// Response
{ "status": true, "message": "Quiz submitted" }
```

#### 🔴 `POST /courses/{courseId}/modules/{moduleId}/complete` — NOT VERIFIED
```json
// Request (empty body)

// Expected Response
{ "status": true, "message": "Module marked as complete" }
```

#### `POST /courses/{courseId}/modules`
```json
// Request
{
  "title": "Module 3 - Advanced Topics",
  "type": "video",
  "order": 3,
  "duration_hours": 4,
  "reminder_days": 7
}

// Response
{ "status": true, "message": "Module created", "data": { "id": "m3", ... } }
```

---

## 📝 4. Reports APIs

| # | Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|---|
| 19 | `GET` | `/reports/progress` | ✅ | ✅ Working | Student progress reports |
| 20 | `GET` | `/reports/progress?studentId={id}` | ✅ | ✅ Working | Specific student progress |
| 21 | `GET` | `/reports` | ✅ | ✅ Working | All reports / flagged reports list |
| 22 | `GET` | `/reports/flagged` | ✅ | ✅ Working | Flagged reports (fallback endpoint) |
| 23 | `GET` | `/reports/{id}` | ✅ | ✅ Working | Single report detail |
| 24 | `POST` | `/reports/{id}/override` | ✅ | ✅ Working | Override a flagged report |
| 25 | `POST` | `/reports/{id}/resolve` | ✅ | ✅ Working | Resolve a report |
| 26 | `POST` | `/reports/approve/{submissionId}` | ✅ | ✅ Working | Approve a report |
| 27 | `POST` | `/reports/reject/{submissionId}` | ✅ | ✅ Working | Reject a report |
| 28 | `POST` | `/reports/submit` | ✅ | ✅ Working | Submit a new report (supports file upload) |

### Request/Response Details:

#### `POST /reports/submit`
```json
// Request (multipart/form-data if file attached)
{
  "course_id": "1",
  "unit_id": "m1",
  "submodule_id": "sm1",
  "activity_title": "Field Visit Report",
  "description": "Visited the factory...",
  "category": "practical",
  "attachment": "<file>"
}

// Response
{ "status": true, "message": "Report submitted successfully" }
```

#### `POST /reports/{id}/override`
```json
// Request
{ "comments": "Overriding due to faculty error." }
```

#### `POST /reports/reject/{submissionId}`
```json
// Request (optional)
{ "reason": "Incomplete information provided." }
```

---

## 📢 5. Notices APIs

| # | Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|---|
| 29 | `GET` | `/notices` | ✅ | ✅ Working | List all notices |
| 30 | `GET` | `/notices/{id}` | ✅ | ✅ Working | Notice detail |
| 31 | `POST` | `/notices/{id}/read` | ✅ | ✅ Working | Mark notice as read |
| 32 | `POST` | `/notices` | ✅ | ✅ Working | Create a new notice (Admin only) |

#### `POST /notices` (Create)
```json
// Request
{
  "title": "Exam Schedule Update",
  "content": "Final exams will start from...",
  "category": "academic",
  "priority": "high",
  "is_pinned": true,
  "target_audience": "all"
}
```

---

## 📅 6. Events APIs

| # | Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|---|
| 33 | `GET` | `/events` | ✅ | ✅ Working | List all events |

---

## 🏆 7. Certificates APIs

| # | Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|---|
| 34 | `GET` | `/certificates` | ✅ | ✅ Working | List all certificates |
| 35 | `GET` | `/certificates/{id}` | ✅ | ✅ Working | Certificate detail |

---

## 🏫 8. School Network APIs

| # | Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|---|
| 36 | `GET` | `/schools` | ✅ | ✅ Working | List all schools |
| 37 | `GET` | `/schools/{id}` | ✅ | ✅ Working | School detail |
| 38 | `GET` | `/students` | ✅ | ✅ Working | List all students (supports `?year=&school=&course=` filters) |
| 39 | `GET` | `/classes` | ✅ | ✅ Working | List all classes |

---

## 📋 9. General Data APIs (used by Dashboard/Sidebar)

| # | Method | Endpoint | Auth | Status | Description |
|---|---|---|---|---|---|
| 40 | `GET` | `/faculties` | ✅ | ✅ Working | List all faculty members |
| 41 | `GET` | `/faculties/{id}` | ✅ | ✅ Working | Faculty member detail |
| 42 | `GET` | `/schedules` | ✅ | ✅ Working | List schedules |
| 43 | `GET` | `/subjects` | ✅ | ✅ Working | List subjects |
| 44 | `GET` | `/syllabus` | ✅ | ✅ Working | List syllabus items |
| 45 | `GET` | `/timetable` | ✅ | ✅ Working | List timetable entries |

---

## 🔴 APIs That Backend Needs to Build / Fix

### Priority 1: Critical (App UI is broken without these)

| # | Method | Endpoint | Issue | Expected Behavior |
|---|---|---|---|---|
| 1 | `GET` | `/faculty/courses/{courseId}/students` | Returns **404** | Should return list of enrolled students with `name`, `roll_no`, `class`, `progress_percent` |
| 2 | `GET` | `/admin/submissions/pending?courseId={courseId}` | Returns **404** | Should return list of pending submissions with `student_name`, `module_title`, `status`, `file_url`, `submitted_at` |

### Priority 2: Important (Feature works with fallback but needs real data)

| # | Method | Endpoint | Issue | Expected Behavior |
|---|---|---|---|---|
| 3 | `POST` | `/courses/{courseId}/modules/{moduleId}/complete` | **Not verified** — may not exist | Should accept empty POST body and mark the module as completed for the authenticated student |
| 4 | — | MCQ Questions in `/courses/{id}` response | Returns **empty** `mcq_questions` array | Should return quiz questions with `question_text`, `explanation`, `options[]` with `is_correct` flag |

### Priority 3: Nice to Have (Future features)

| # | Method | Endpoint | Notes |
|---|---|---|---|
| 5 | `GET` | `/courses/{courseId}/certificate` | For downloading course completion certificates |
| 6 | `POST` | `/auth/refresh-token` | For token refresh logic (currently not implemented) |
| 7 | `GET` | `/gallery` | Dedicated gallery endpoint (currently mock) |
| 8 | `PUT` | `/profile/update` | Edit profile endpoint |
| 9 | `POST` | `/reports/export` | Data export as CSV/Excel |

---

## 🔒 Security Notes for Backend Team

1. **All endpoints** require `Authorization: Bearer <token>` header (except auth login/register).
2. **Role-based access control** should be enforced server-side:
   - Students: Can only access their own data, enroll in courses, submit reports.
   - Faculty: Can view their assigned courses' students, review submissions.
   - Admin/Coordinator: Can see all schools, approve/reject submissions, create notices.
   - Principal: Dashboard overview access.
3. **File uploads** use `multipart/form-data` format (reports submission).
4. **Pagination** is expected for large lists — app handles `{ data: { data: [...], total: N } }` pattern.

---

## 📱 App-Side Fallback Behavior

The app has been designed to gracefully handle missing APIs:

| Missing API | App Behavior |
|---|---|
| `/faculty/courses/{id}/students` (404) | Shows mock student cards with sample data |
| `mcq_questions` empty | Shows dummy quiz questions for UI testing |
| Any API failure | Shows error state with "Retry" button |
| Offline | Queues report submissions for later sync |

---

*Generated from codebase analysis on 2026-06-16*
