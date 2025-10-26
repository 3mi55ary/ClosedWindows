# === INSTALL ===
# Download YARA
curl.exe -L "https://github.com/VirusTotal/yara/releases/download/v4.5.4/yara-master-v4.5.4-win64.zip" -o "$PWD\yara.zip"
Expand-Archive -Path "$PWD\yara.zip" -DestinationPath "$env:LocalAppData\YARA" -Force
Remove-Item "$PWD\yara.zip"

# Download Visual C++ Redistributable
curl.exe -L "https://aka.ms/vs/17/release/vc_redist.x64.exe" -o "$PWD\vcredist.exe"
Start-Process "$PWD\vcredist.exe" -ArgumentList "/install", "/quiet" -Wait
Remove-Item "$PWD\vcredist.exe"

# Download YARA Rules
curl.exe -L "https://github.com/sivolko/comprehensive-yara-rules/archive/refs/heads/main.zip" -o "$PWD\yararules.zip"
Expand-Archive -Path "$PWD\yararules.zip" -DestinationPath "$env:LocalAppData\YARA" -Force
Remove-Item "$PWD\yararules.zip"

Remove-Item -Path "$env:LocalAppData\YARA\comprehensive-yara-rules-main\cloud" -Recurse -Force

# === CONFIG ===
$rulesPath   = "$env:LocalAppData\YARA\comprehensive-yara-rules-main"
$targetPath  = "C:\"
$logPath     = "$env:LocalAppData\YARA\scanlog.txt"
$intervalSec = 180

# === LOOP ===
while ($true) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content $logPath "`n[$timestamp] Starting YARA scan on $targetPath"

    Get-ChildItem -Path $rulesPath -Filter *.yar -Recurse | ForEach-Object {
        $rule     = $_.FullName
        $ruleName = $_.BaseName
        try {
            $result = & "$env:LocalAppData\YARA\yara64.exe" -r $rule $targetPath 2>&1
            $cleanResult = $result | Where-Object { $_ -notmatch "could not open file" }

            if ($LASTEXITCODE -eq 0 -and $cleanResult) {
                Add-Content $logPath "`n[$timestamp] Rule: $ruleName"
                Add-Content $logPath $cleanResult
            }
        } catch {
            Add-Content $logPath "`n[$timestamp] ERROR running rule: $ruleName"
            Add-Content $logPath $_.Exception.Message
        }
    }

    Add-Content $logPath "`n[$timestamp] Scan complete."
    Start-Sleep -Seconds $intervalSec
}