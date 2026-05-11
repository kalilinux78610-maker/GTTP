# GTTP
**The Global Travel and Tourism Partnership**

A modern Flutter mobile application built with secure, highly-scalable Clean Architecture.

## API Coverage
- Auth: `/auth/login`, `/auth/verify-otp`, `/auth/resend-otp`, `/auth/forgot-password`, `/auth/reset-password`
- Dashboard: `/dashboard`
- Master Data: `/certificates`, `/schedules`, `/subjects`, `/syllabus`, `/timetable`, `/notices`, `/schools`, `/students`, `/classes`

## Recent Updates
- Events parsing now supports both list payloads and single-object payloads in `data`.
- Courses parsing now supports `cover_image` for thumbnails and `total_hours` for duration.
- Courses description text is now sanitized from HTML, and relative course images are resolved through `/storage/...`.
- Events image parsing now resolves relative image paths through `/storage/...` for reliable rendering.
- Courses UI now shows API settings details: start/end dates, enrollment type, status, and pass percentage.
- Reports UI now shows a dedicated "Coming Soon" state for the `Flagged` review filter.
