$token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2d0dHAuZWZzb3Vscy5jb20vYXBpL2F1dGgvdmVyaWZ5LW90cCIsImlhdCI6MTc4MDM5OTI5MiwiZXhwIjoxNzgwNDAyODkyLCJuYmYiOjE3ODAzOTkyOTIsImp0aSI6IjdvaTJZU1JVTG9EcHIyZTgiLCJzdWIiOiI0MyIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.t0J7loXORKMCXKB3UMQ5ra_2Nc19rdaF8pqwJpad4e4'
$headers = @{ Authorization = "Bearer $token" }
$endpoints = @(
    'dashboard', 'certificates', 'schedules', 'subjects', 'syllabus', 
    'timetable', 'notices', 'schools', 'classes', 'courses', 'events', 
    'reports/progress', 'faculties', 'student/dashboard', 
    'national-coordinator/dashboard', 'principal/dashboard',
    'courses/1', 'faculties/3'
)

$results = @{}
foreach ($endpoint in $endpoints) {
    try {
        Write-Output "Fetching $endpoint ..."
        $response = Invoke-RestMethod -Uri "https://gttp.efsouls.com/api/$endpoint" -Method Get -Headers $headers
        $results[$endpoint] = $response
    } catch {
        $results[$endpoint] = $_.Exception.Message
    }
}

$results | ConvertTo-Json -Depth 10 | Out-File 'api_responses_student.json'
Write-Output 'Saved to api_responses_student.json'
