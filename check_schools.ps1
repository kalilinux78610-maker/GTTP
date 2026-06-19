$token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2d0dHAuZWZzb3Vscy5jb20vYXBpL2F1dGgvdmVyaWZ5LW90cCIsImlhdCI6MTc4MDM5OTI5MiwiZXhwIjoxNzgwNDAyODkyLCJuYmYiOjE3ODAzOTkyOTIsImp0aSI6IjdvaTJZU1JVTG9EcHIyZTgiLCJzdWIiOiI0MyIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.t0J7loXORKMCXKB3UMQ5ra_2Nc19rdaF8pqwJpad4e4'
$headers = @{ Authorization = "Bearer $token" }

try {
    $response = Invoke-RestMethod -Uri "https://gttp.efsouls.com/api/schools" -Method Get -Headers $headers
    $response | ConvertTo-Json -Depth 4 | Out-File "debug_schools.json"
} catch {
    Write-Output $_.Exception.Message
}
