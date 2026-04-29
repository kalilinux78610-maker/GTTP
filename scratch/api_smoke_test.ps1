$ErrorActionPreference = 'Stop'
$base = 'https://gttp.efsouls.com/api'
$json = @{
    'Content-Type' = 'application/json'
    'Accept'       = 'application/json'
}

function Read-ErrorBody($ex) {
    try {
        $resp = $ex.Exception.Response
        if ($null -eq $resp) { return $ex.Message }
        $stream = $resp.Content.ReadAsStream()
        $reader = [System.IO.StreamReader]::new($stream)
        return $reader.ReadToEnd()
    } catch {
        return $ex.Message
    }
}

function Show-Response($name, $statusCode, $body) {
    Write-Host "`n======== $name ========"
    Write-Host "HTTP $statusCode"
    if ($null -ne $body -and $body -ne '') { Write-Host $body }
}

# 1 Login — invalid user
try {
    $r = Invoke-WebRequest -Uri "$base/auth/login" -Method POST -Headers $json `
        -Body (@{ email = 'not-a-real-user@example.com'; password = 'wrong' } | ConvertTo-Json) `
        -UseBasicParsing -TimeoutSec 30
    Show-Response 'POST /auth/login' $r.StatusCode $r.Content
} catch {
    Show-Response 'POST /auth/login' $_.Exception.Response.StatusCode.value__ (Read-ErrorBody $_)
}

# 2 Forgot password
try {
    $r = Invoke-WebRequest -Uri "$base/auth/forgot-password" -Method POST -Headers $json `
        -Body (@{ email = 'not-a-real-user@example.com' } | ConvertTo-Json) `
        -UseBasicParsing -TimeoutSec 30
    Show-Response 'POST /auth/forgot-password' $r.StatusCode $r.Content
} catch {
    Show-Response 'POST /auth/forgot-password' $_.Exception.Response.StatusCode.value__ (Read-ErrorBody $_)
}

# 3 Verify OTP
try {
    $r = Invoke-WebRequest -Uri "$base/auth/verify-otp" -Method POST -Headers $json `
        -Body (@{ user_id = 999999999; otp = '123456' } | ConvertTo-Json) `
        -UseBasicParsing -TimeoutSec 30
    Show-Response 'POST /auth/verify-otp' $r.StatusCode $r.Content
} catch {
    Show-Response 'POST /auth/verify-otp' $_.Exception.Response.StatusCode.value__ (Read-ErrorBody $_)
}

# 4 Resend OTP — multipart
try {
    $r = Invoke-WebRequest -Uri "$base/auth/resend-otp" -Method POST `
        -Headers @{ 'Accept' = 'application/json' } `
        -Form @{ user_id = '999999999' } -UseBasicParsing -TimeoutSec 30
    Show-Response 'POST /auth/resend-otp' $r.StatusCode $r.Content
} catch {
    Show-Response 'POST /auth/resend-otp' $_.Exception.Response.StatusCode.value__ (Read-ErrorBody $_)
}

# 5 Reset password
try {
    $r = Invoke-WebRequest -Uri "$base/auth/reset-password" -Method POST -Headers $json `
        -Body (@{
                email                   = 'not-a-real-user@example.com'
                otp                     = '123456'
                password                = 'NewPass123!'
                password_confirmation   = 'NewPass123!'
            } | ConvertTo-Json) `
        -UseBasicParsing -TimeoutSec 30
    Show-Response 'POST /auth/reset-password' $r.StatusCode $r.Content
} catch {
    Show-Response 'POST /auth/reset-password' $_.Exception.Response.StatusCode.value__ (Read-ErrorBody $_)
}

# 6 Dashboard — no auth
try {
    $r = Invoke-WebRequest -Uri "$base/dashboard" -Method GET -Headers $json `
        -UseBasicParsing -TimeoutSec 30
    Show-Response 'GET /dashboard' $r.StatusCode $r.Content
} catch {
    Show-Response 'GET /dashboard' $_.Exception.Response.StatusCode.value__ (Read-ErrorBody $_)
}
