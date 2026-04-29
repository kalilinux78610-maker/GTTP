# Task Log

## 2026-04-21
- Add all APIs from `gttp_api_collection.json` into app datasource/providers.
- Wire School Network to live `/schools` API with fallback mock data.
- Normalize school JSON parsing for snake_case and camelCase backend keys.
- Remove mock data and fallback paths; use real APIs only for School Network, Reports, and Export flow.
- Provide latest API details and test cases in docs and `.http` test suite.
