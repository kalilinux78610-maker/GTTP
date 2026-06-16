```text
📌 API Reference: Student Upload / Submit Report

Hi! The app is already integrated and sending requests to this endpoint for students to upload their assignment reports. Here is the exact payload structure the app sends so you can build the backend to accept it.

Endpoint: POST /api/reports/submit
Auth: Bearer Token (required)
Method: POST
Content-Type: multipart/form-data (if file attached) OR application/json

Form Data / JSON Fields the app sends:
✅ activity_title (string, required) — The title of the assignment/report
✅ description (string, required) — The student's text/notes
✅ category (enum string, required) — Exact values sent: "field_trip", "assignment", or "practical"
- course_id (string, optional) — The ID of the course this belongs to
- unit_id (string, optional) — Refers to the module_id this belongs to
- submodule_id (string, optional)
- attachment (File / Multipart, optional) — The actual PDF/Image file uploaded by the student

Expected Response from Backend (200 OK):
{
  "status": true,
  "message": "Report submitted successfully"
}

Database Tables Involved:
This should save into a `student_submissions` table with columns:
- id, student_id (FK), course_id (FK), module_id (FK)
- requirement_title, file_url, notes, status (default: pending_review)
- submitted_at (timestamp)

Status: ✅ The mobile app is already sending this exact format. You just need to ensure the backend receives and saves it.
```
