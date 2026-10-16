$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "Install Go manually, then reopen PowerShell and rerun this script."
    }
    winget install --id GoLang.Go --exact --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { throw "Go installation failed." }
    throw "Go was installed. Reopen PowerShell and rerun this script."
}

$archive = Join-Path $PWD "age-latest.tar.gz"
$proof = Join-Path $PWD "age-latest.tar.gz.proof"
$installDir = Join-Path $env:TEMP "age-install"
$platform = "windows/amd64"

Remove-Item $archive, $proof, $installDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $installDir | Out-Null

try {
    curl.exe --fail --location `
        "https://dl.filippo.io/age/latest?for=$platform" --output $archive
    if ($LASTEXITCODE -ne 0) { throw "Downloading age failed." }

    curl.exe --fail --location `
        "https://dl.filippo.io/age/latest?for=$platform&proof" --output $proof
    if ($LASTEXITCODE -ne 0) { throw "Downloading the proof failed." }

    $env:GOPROXY = "direct"
    go install sigsum.org/sigsum-go/cmd/sigsum-verify@latest
    if ($LASTEXITCODE -ne 0) { throw "Installing sigsum-verify failed." }

    $goBin = (go env GOBIN).Trim()
    if (-not $goBin) { $goBin = Join-Path (go env GOPATH).Trim() "bin" }
    $sigsumVerify = Join-Path $goBin "sigsum-verify.exe"
    if (-not (Test-Path $sigsumVerify)) { throw "sigsum-verify not found at $sigsumVerify" }

    $trustedKeys = Join-Path $installDir "trusted-keys"
    @(
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM1WpnEswJLPzvXJDiswowy48U+G+G1kmgwUE2eaRHZG"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAz2WM5CyPLqiNjk7CLl4roDXwKhQ0QExXLebukZEZFS"
    ) | Set-Content -Encoding ascii $trustedKeys

    # Pass the archive as binary stdin to the verifier.
    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = $sigsumVerify
    $psi.Arguments = "-k `"$trustedKeys`" -P sigsum-generic-2025-1 `"$proof`""
    $psi.UseShellExecute = $false
    $psi.RedirectStandardInput = $true
    $process = [System.Diagnostics.Process]::Start($psi)
    $fileStream = [System.IO.File]::OpenRead($archive)
    try { $fileStream.CopyTo($process.StandardInput.BaseStream) }
    finally {
        $fileStream.Dispose()
        $process.StandardInput.Close()
    }
    $process.WaitForExit()
    if ($process.ExitCode -ne 0) { throw "Sigsum verification failed; age was not installed." }

    tar.exe -xzf $archive --strip-components=1 -C $installDir
    if ($LASTEXITCODE -ne 0) { throw "Extracting the archive failed." }

    $binDir = Join-Path $env:LOCALAPPDATA "Programs\age"
    New-Item -ItemType Directory -Force -Path $binDir | Out-Null
    Copy-Item (Join-Path $installDir "age.exe"), (Join-Path $installDir "age-keygen.exe") $binDir

    $keyDir = Join-Path $HOME ".ssh"
    New-Item -ItemType Directory -Force -Path $keyDir | Out-Null
    $privateKey = Join-Path $keyDir "thislaptop-pq-key.txt"
    $publicKey = Join-Path $keyDir "thislaptop-pq.pub"

    & (Join-Path $binDir "age-keygen.exe") -pq -o $privateKey
    if ($LASTEXITCODE -ne 0) { throw "Key generation failed." }
    & (Join-Path $binDir "age-keygen.exe") -y $privateKey | Set-Content -Encoding ascii $publicKey

    Write-Host "Installed age in $binDir"
    Write-Host "Private key: $privateKey"
    Write-Host "Public key:  $publicKey"
    Write-Host "Add $binDir to your user PATH to run age from any terminal."
}
finally {
    Remove-Item $archive, $proof, $installDir -Recurse -Force -ErrorAction SilentlyContinue
}
