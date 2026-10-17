$ErrorActionPreference = "Stop"

$keyDir = Join-Path $HOME ".ssh"
New-Item -ItemType Directory -Force -Path $keyDir | Out-Null

$stamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
$keyPath = Join-Path $keyDir "vps4wireguard-$stamp"
$comment = "vps4wireguard-$stamp"

ssh-keygen -q -t ed25519 -a 100 -f $keyPath -C $comment
if ($LASTEXITCODE -ne 0) { throw "ssh-keygen failed." }

# Start the Windows OpenSSH agent. Starting the service may require
# opening PowerShell as Administrator if the service is disabled.
Set-Service ssh-agent -StartupType Manual
Start-Service ssh-agent
ssh-add $keyPath
if ($LASTEXITCODE -ne 0) { throw "ssh-add failed." }

$configPath = Join-Path $keyDir "config"
$configEntry = @"

Host vps4wireguard
    HostName YourVPSip
    User root
    Port 22
    IdentityFile "$($keyPath -replace '\\','/')"
    IdentitiesOnly yes
"@

Add-Content -Path $configPath -Value $configEntry

Write-Host "Private key: $keyPath"
Write-Host "Public key:  $keyPath.pub"
