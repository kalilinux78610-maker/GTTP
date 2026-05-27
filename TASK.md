# Task Log

## 2026-04-21
- Add all APIs from `gttp_api_collection.json` into app datasource/providers.
- Wire School Network to live `/schools` API with fallback mock data.
- Normalize school JSON parsing for snake_case and camelCase backend keys.
- Remove mock data and fallback paths; use real APIs only for School Network, Reports, and Export flow.
- Provide latest API details and test cases in docs and `.http` test suite.

## 2026-05-06
- Handle `/events` API payload when `data` is a single object instead of only a list.
- Support `/courses` payload keys `cover_image` and `total_hours` in `CourseModel` parsing.
- Fix courses UI data mapping: resolve `cover_image` via `/storage` path and strip HTML tags from description.
- Fix events image URL resolution for relative paths by normalizing to `/storage/...`.
- Show course settings details in app UI (`start_date`, `end_date`, `enrollment_type`, `status`, `pass_percentage`).
- Fix course pass-percentage chip formatting to avoid duplicate `%` display.
- Add "Coming Soon" placeholder for `Flagged Reports Review` filter state.

## 2026-05-12
- Fix course cover image URLs: parse API origin from `API_BASE_URL`, avoid double slashes, accept `cover_image_url` / full `https` URLs from API.
