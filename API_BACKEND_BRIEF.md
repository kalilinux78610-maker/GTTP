## GTTP mobile app ↔ API integration brief (Latest)

### Environment
- **API base URL (mobile):** `https://gttp.efsouls.com/api` (from app `API_BASE_URL`)

### Required HTTP headers (important)
The mobile client sends:
- `Content-Type: application/json` for JSON bodies  
- **`Accept: application/json`** on all requests  

**Why:** Without `Accept: application/json`, Laravel sometimes returns **HTML** (e.g. Filament admin login) instead of JSON on auth failures. With this header we get proper JSON (e.g. `401 {"message":"Unauthenticated."}`).

---

## Endpoints the app uses

### 1. Login  
**`POST /auth/login`**

**Request body:**
```json
{ "email": "user@example.com", "password": "..." }
```

**Expected success (one of):**
- **A)** Access token present (app looks for any of): `accessToken`, `token`, `access_token`, `jwt`, `bearerToken`  
- Optional refresh: `refreshToken`, `refresh_token`, `refreshJwt`  
- **B)** **2FA / OTP before token:** no access token yet, but **`user_id`** present (app looks for: `user_id`, `userId`, `id`) — user is sent to OTP screen  

**Nested JSON:** App also reads those fields under `data` and `data.user` if you wrap responses.

**Observed error (example):** `401` with `{"error":"Invalid credentials"}` — OK if `error` or `message` is a string.

---

### 2. Forgot password (triggers OTP flow)  
**`POST /auth/forgot-password`**

**Request body:**
```json
{ "email": "user@example.com" }
```

**Expected success:** Response must include **`user_id`** (same key variants as above) so the app can call verify/resend OTP.

**Observed error (example):** `404` with `{"error":"No account found with this email address"}` — OK.

---

### 3. Verify OTP  
**`POST /auth/verify-otp`**

**Request body:**
```json
{ "user_id": 123, "otp": "123456" }
```

**Expected success:** Ideally returns **access token** (same token key variants as login) + optional refresh token. App clears stored `user_id` after this call.

**Observed error (example):** `422` with validation payload for invalid `user_id` / OTP — OK if there is a clear user-facing message.

---

### 4. Resend OTP  
**`POST /auth/resend-otp`**

**Request:** **`multipart/form-data`** with field **`user_id`** (string or number as form field).

**Note:** This matches how the API was tested in Postman; JSON-only for this route may not match server validation.

---

### 5. Reset password (after OTP in “forgot password” flow)  
**`POST /auth/reset-password`**

**Request body (Laravel-style — required by your API):**
```json
{
  "email": "user@example.com",
  "otp": "123456",
  "password": "NewStrongPass1!",
  "password_confirmation": "NewStrongPass1!"
}
```

**Issue we fixed on mobile:** The app used to send `newPassword` only; your API returns **422** expecting `password` + `password_confirmation`. Mobile now matches this.

---

### 6. Dashboard (after login)  
**`GET /dashboard`**  
**Headers:** `Authorization: Bearer <access_token>` + `Accept: application/json`

**Expected success JSON (either shape is OK):**
- **A)** `{ "data": { ...counts } }`  
- **B)** `{ ...counts }` at root  

**Counts the app maps today (snake_case or camelCase):**
- `total_students` / `totalStudents`  
- `total_classes` / `totalClasses`  
- `total_notices` / `totalNotices`  
- `total_schedules` / `totalSchedules`  
- `total_syllabi` / `totalSyllabi`  
- `total_certificates` / `totalCertificates`  
- `total_users` / `totalUsers`  

If your API uses different names, please either **rename** to the above or **publish the real JSON sample** so mobile can map it.

---

## Additional latest master-data endpoints

All routes below are protected and require:
- `Authorization: Bearer <access_token>`
- `Accept: application/json`

### 7. Certificates
**`GET /certificates`**

### 8. Schedules
**`GET /schedules`**

### 9. Subjects
**`GET /subjects`**

### 10. Syllabus
**`GET /syllabus`**

### 11. Timetable
**`GET /timetable`**

### 12. Notices
**`GET /notices`**

### 13. Schools
**`GET /schools`**

### 14. Students
**`GET /students`**

### 15. Classes
**`GET /classes`**

---

## Test cases (latest)

### Auth flow
1. **Login success**
   - Request: valid email/password
   - Expect: `200`, and either token keys (`token`/`access_token`) or `user_id` for OTP flow.

2. **Login invalid credentials**
   - Request: wrong password
   - Expect: `401` with JSON string `message` or `error`.

3. **Verify OTP success**
   - Request: valid `user_id` + valid `otp`
   - Expect: `200` with access token.

4. **Verify OTP invalid**
   - Request: wrong/expired OTP
   - Expect: `4xx` with clear JSON message.

5. **Resend OTP success**
   - Request: `multipart/form-data` with `user_id`
   - Expect: `200` with success message.

6. **Forgot password success**
   - Request: registered email
   - Expect: `200` and `user_id` returned.

7. **Reset password success**
   - Request: valid email/otp/password/password_confirmation
   - Expect: `200`, password reset success message.

### Protected endpoints
8. **Protected without token**
   - Request: any protected GET without `Authorization`
   - Expect: `401` JSON (not HTML).

9. **Protected with invalid token**
   - Request: any protected GET with bad token
   - Expect: `401` JSON.

10. **Protected with valid token**
    - Request: each of `/dashboard`, `/certificates`, `/schedules`, `/subjects`, `/syllabus`, `/timetable`, `/notices`, `/schools`, `/students`, `/classes`
    - Expect: `200` JSON list/object with stable shape.

---

## Problems to solve on the backend (action items)

1. **Standardize error JSON for mobile**  
   For `4xx/5xx`, please always include a **top-level string**:
   - `message` **or** `error`  
   Even when you also return Laravel `errors` / `details`.  
   Mobile currently surfaces string `message`/`error` best; nested-only validation can show a generic message.

2. **Confirm OTP + token contract**  
   Please document for each path:
   - Login with 2FA: exact JSON when OTP is required (token absent, `user_id` present?).  
   - `verify-otp`: exact token field names and HTTP status on success/failure.  
   - Forgot password: confirm `user_id` is always returned on success.

3. **Confirm dashboard contract**  
   Provide one **real authenticated 200** response example for `GET /dashboard` (or change the route if dashboard is elsewhere).

4. **Email delivery (OTP)**  
   If users never receive OTP, that’s **mail/queue/config** on the server; mobile can’t fix that.

---

## Quick test checklist for backend (curl/Postman)
- `POST /auth/login` invalid creds → `401` JSON with string `message` or `error`  
- `POST /auth/forgot-password` unknown email → `404` JSON  
- `POST /auth/verify-otp` bad id → `422` JSON + clear message  
- `GET /dashboard` no token + `Accept: application/json` → `401` JSON (not HTML)  
- `GET /dashboard` valid token → `200` JSON with stats in `data` or root  

---

If you want, paste **one real success JSON** for login, verify-otp, and dashboard here and we can align the app 1:1 with no guesswork.
