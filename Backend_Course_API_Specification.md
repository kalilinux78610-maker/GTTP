# Backend API Specification: Course Task Upload & Approval Workflow

This document outlines the required REST API endpoints to support the interactive "Task Upload & Approval" workflow in the mobile application.

## Overview of Workflow
1. **Student** enrolls in a course.
2. **Student** reaches a module, uploads a task (image/PDF) along with optional notes.
3. **Super Admin / National Coordinator** fetches a list of pending tasks across the platform.
4. **Admin** approves or rejects the task with feedback.
5. Once all modules for a course are approved, the student's progress hits 100%, and they can download a **Certificate**.

---

## 1. Enroll Student in Course
Triggered when a student clicks the "Start Course" button.

*   **Endpoint:** `POST /api/courses/{courseId}/enroll`
*   **Headers:** 
    *   `Authorization: Bearer <token>`
*   **Request Body:** (Empty)
*   **Expected Response (200 OK):**
    ```json
    {
      "status": "success",
      "message": "Enrolled successfully",
      "data": {
        "is_enrolled": true,
        "enrollment_date": "2026-05-28T10:00:00Z"
      }
    }
    ```

---

## 2. Submit Task / Upload Document (Student)
Triggered when a student completes a module task and uploads their proof of work.

*   **Endpoint:** `POST /api/courses/{courseId}/modules/{moduleId}/submit`
*   **Headers:** 
    *   `Authorization: Bearer <token>`
    *   `Content-Type: multipart/form-data`
*   **Request Payload (Form Data):**
    *   `file`: The actual file bytes (Image, PDF, Document).
    *   `notes` *(Optional)*: Any text notes the student added.
*   **Expected Response (200 OK):**
    ```json
    {
      "status": "success",
      "message": "Task submitted successfully. Awaiting admin review.",
      "data": {
        "submission_id": "sub_987654",
        "review_status": "pending_review",
        "submitted_at": "2026-05-28T10:05:00Z"
      }
    }
    ```

---

## 3. Get Pending Submissions (Admin)
Triggered when an Admin or Coordinator opens their dashboard to review student work.

*   **Endpoint:** `GET /api/admin/submissions/pending`
*   **Query Parameters (Optional):**
    *   `?courseId=123` (Filter by specific course)
    *   `?page=1&limit=20` (For pagination)
*   **Headers:** 
    *   `Authorization: Bearer <token>`
*   **Expected Response (200 OK):**
    ```json
    {
      "status": "success",
      "data": [
        {
          "submission_id": "sub_987654",
          "student_name": "Shreyansh Vasava",
          "course_id": "course_101",
          "course_name": "Travel & Tourism 101",
          "module_name": "Assignment 1",
          "file_url": "https://your-storage-bucket.com/uploads/student_task.png",
          "notes": "Attached is my research report.",
          "submitted_at": "2026-05-28T10:05:00Z",
          "status": "pending_review"
        }
      ]
    }
    ```

---

## 4. Get Class Enrolled Students (Faculty / Teacher)
Triggered when a Teacher opens their Course Details screen to track student progress.

*   **Endpoint:** `GET /api/faculty/courses/{courseId}/students`
*   **Headers:** 
    *   `Authorization: Bearer <token>`
*   **Expected Response (200 OK):**
    ```json
    {
      "status": "success",
      "data": [
        {
          "student_id": "stud_001",
          "name": "Ananya Sharma",
          "roll_no": "24",
          "class": "10-A",
          "progress_percent": 75
        },
        {
          "student_id": "stud_002",
          "name": "Rohan Kumar",
          "roll_no": "12",
          "class": "10-A",
          "progress_percent": 40
        }
      ]
    }
    ```

---

## 5. Approve or Reject Task (Admin)
Triggered when the Admin clicks "Approve" or "Reject" on a student's pending task.

*   **Endpoint:** `POST /api/admin/submissions/{submissionId}/review`
*   **Headers:** 
    *   `Authorization: Bearer <token>`
    *   `Content-Type: application/json`
*   **Request Body (JSON):**
    ```json
    {
      "status": "approved", // Must be "approved" or "rejected"
      "feedback_notes": "Great work on this task! Everything looks correct." 
    }
    ```
*   **Expected Response (200 OK):**
    ```json
    {
      "status": "success",
      "message": "Submission has been approved.",
      "data": {
        "submission_id": "sub_987654",
        "new_status": "approved"
      }
    }
    ```
*(Note: Once a module is approved, the backend should update the overall course `progress_percent` for that student so the mobile app can display it).*

---

## 5. Download Certificate
Triggered when the student's progress reaches 100% and they request their certificate.

*   **Endpoint:** `GET /api/courses/{courseId}/certificate`
*   **Headers:** 
    *   `Authorization: Bearer <token>`
*   **Expected Response:**
    *   **Option A (Preferred):** Return a JSON object with a direct download URL.
        ```json
        {
          "status": "success",
          "data": {
            "certificate_url": "https://your-storage-bucket.com/certificates/cert_1234.pdf"
          }
        }
        ```
    *   **Option B:** Return the raw PDF file bytes directly with the header `Content-Type: application/pdf`.
