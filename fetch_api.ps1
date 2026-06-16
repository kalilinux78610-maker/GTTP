$email = 'muffadalbodgam@efsouls.com'
$password = 'password'
$loginBody = @{ email = $email; password = $password } | ConvertTo-Json
$loginResponse = Invoke-RestMethod -Uri 'https://gttp.efsouls.com/api/auth/login' -Method Post -Body $loginBody -ContentType 'application/json'

$token = $null
if ($loginResponse.data -and $loginResponse.data.token) {
    $token = $loginResponse.data.token
} elseif ($loginResponse.token) {
    $token = $loginResponse.token
}

if (-not $token) {
    Write-Output 'Failed to get token'
    $loginResponse | ConvertTo-Json -Depth 10
    exit
}

Write-Output 'Token retrieved successfully.'

$headers = @{ Authorization = "Bearer $token" }
$endpoints = @(
    'dashboard', 'certificates', 'schedules', 'subjects', 'syllabus', 
    'timetable', 'notices', 'schools', 'classes', 'courses', 'events', 
    'reports/progress', 'faculties', 'student/dashboard', 
    'national-coordinator/dashboard', 'principal/dashboard'
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

$results | ConvertTo-Json -Depth 10 | Out-File 'api_responses.json'
Write-Output 'Saved to api_responses.json'
