$ErrorActionPreference = "Stop"

$keyDir = Join-Path $HOME ".ssh"
New-Item -ItemType Directory -Force -Path $keyDir | Out-Null

$stamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
$keyPath = Join-Path $keyDir "vps4wireguard-$stamp"
$comment = "vps4wireguard-$stamp"

ssh-keygen -q -t ed25519 -a 100 -f $keyPath -C $comment
if ($LASTEXITCODE -ne 0) { throw "ssh-keygen failed." }

# Start the Windows OpenSSH agent. Configuring or starting it may require
# PowerShell to be run as Administrator.
Set-Service ssh-agent -StartupType Manual
Start-Service ssh-agent
ssh-add $keyPath
if ($LASTEXITCODE -ne 0) { throw "ssh-add failed." }

$pubKey = & ssh-keygen -y -f $keyPath
if ($LASTEXITCODE -ne 0) { throw "Could not derive the public key." }

$installScript = Join-Path $keyDir "install_vpn_ON_vps.sh"
$scriptText = [System.IO.File]::ReadAllText($installScript)
$placeholder = "METTEZ_VOTRE_CLEF_PUBLIQUE_ICI"

$scriptText = $scriptText.Replace($placeholder, $pubKey)
[System.IO.File]::WriteAllText(
    $installScript,
    $scriptText,
    [System.Text.UTF8Encoding]::new($false)
)
$vpsEndpointFeeder = Read-Host "VPS public IP or DNS name"
$scriptText = $scriptText.Replace("VPS_ENDPOINT", $vpsEndpointFeeder)
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
