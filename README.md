# monVPNperso
all steps from 0 knowledge to 100% installed wireguard vpn, running, affordable, ...



## REQUIREMENTS: A, PC or laptop, running either Linux, or Windows, or MacOS (or derivative) ...


### for Windows users

Open PowerShell or Windows Terminal and install with WinGet:
```
winget install --id FiloSottile.age
```
Close and reopen the terminal, then check that it runs:
```
age --versionage-keygen --help
```

Copy this content into a file and run the file 
```
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

```


### for macOS users

Open Terminal and install with Homebrew:
```
brew install age
```
Check the installation:
```
age --versionage-keygen --help
```
Copy this content into a file and run the file :
```
#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "Install Homebrew first, then rerun this script." >&2
  exit 1
fi

brew install go

case "$(uname -m)" in
  x86_64) platform="darwin/amd64" ;;
  arm64)  platform="darwin/arm64" ;;
  *)
    echo "Unsupported Mac architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

archive="age-latest.tar.gz"
proof="age-latest.tar.gz.proof"
install_dir="$HOME/Downloads/age-install"
key_dir="$HOME/.ssh"

rm -f "$archive" "$proof"
rm -rf "$install_dir"
mkdir -p "$install_dir" "$key_dir"

cleanup() {
  rm -f "$archive" "$proof"
  rm -rf "$install_dir"
}
trap cleanup EXIT

curl -fL \
  "https://dl.filippo.io/age/latest?for=${platform}" \
  -o "$archive"

curl -fL \
  "https://dl.filippo.io/age/latest?for=${platform}&proof" \
  -o "$proof"

GOPROXY=direct go install sigsum.org/sigsum-go/cmd/sigsum-verify@latest

gopath="$(go env GOPATH)"
sigsum_verify="${GOBIN:-$gopath/bin}/sigsum-verify"
[[ -x "$sigsum_verify" ]] || {
  echo "sigsum-verify not found at: $sigsum_verify" >&2
  exit 1
}

printf '%s\n' \
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM1WpnEswJLPzvXJDiswowy48U+G+G1kmgwUE2eaRHZG' \
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAz2WM5CyPLqiNjk7CLl4roDXwKhQ0QExXLebukZEZFS' \
  > "$install_dir/trusted-keys"

"$sigsum_verify" \
  -k "$install_dir/trusted-keys" \
  -P sigsum-generic-2025-1 \
  "$proof" < "$archive"

tar -xzf "$archive" --strip-components=1 -C "$install_dir"
sudo install -m 0755 "$install_dir/age" "$install_dir/age-keygen" /usr/local/bin/

age-keygen -pq -o "$key_dir/thislaptop-pq-key.txt" 2>/dev/null
age-keygen -y "$key_dir/thislaptop-pq-key.txt" > "$key_dir/thislaptop-pq.pub"
chmod 600 "$key_dir/thislaptop-pq-key.txt"

printf 'Private key: %s\nPublic key:  %s\n' \
  "$key_dir/thislaptop-pq-key.txt" \
  "$key_dir/thislaptop-pq.pub"

```


### for Linux users (here Debian-based)
```
#!/usr/bin/env bash
set -euo pipefail

sudo apt update
sudo apt install -y curl tar torsocks golang-go 

arch="$(dpkg --print-architecture)"

case "$arch" in
  amd64) platform="linux/amd64" ;;
  arm64) platform="linux/arm64" ;;
  armhf) platform="linux/arm" ;;
  *)
    echo "Unsupported architecture: $arch" >&2
    exit 1
    ;;
esac

archive="age-latest.tar.gz"
proof="age-latest.tar.gz.proof"
install_dir="$HOME/Downloads/age-install"

rm -f "$archive" "$proof"
rm -rf "$install_dir"
mkdir -p "$install_dir"

torsocks curl -fL \
  "https://dl.filippo.io/age/latest?for=${platform}" \
  -o "$archive"

torsocks curl -fL \
  "https://dl.filippo.io/age/latest?for=${platform}&proof" \
  -o "$proof"

GOPROXY=direct go install sigsum.org/sigsum-go/cmd/sigsum-verify@latest

gopath="$(go env GOPATH)"
sigsum_verify="${GOBIN:-$gopath/bin}/sigsum-verify"

if [[ ! -x "$sigsum_verify" ]]; then
  echo "sigsum-verify was not found at: $sigsum_verify" >&2
  echo "Check Go's installation with: go env GOPATH GOBIN" >&2
  exit 1
fi

"$sigsum_verify" \
  -k <(
    printf '%s\n' \
      'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM1WpnEswJLPzvXJDiswowy48U+G+G1kmgwUE2eaRHZG' \
      'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAz2WM5CyPLqiNjk7CLl4roDXwKhQ0QExXLebukZEZFS'
  ) \
  -P sigsum-generic-2025-1 \
  "$proof" < "$archive"

tar -xzf "$archive" \
  --strip-components=1 \
  -C "$install_dir"

sudo install -m 0755 \
  "$install_dir/age" \
  "$install_dir/age-keygen" \
  /usr/local/bin/

rm -f "$archive" "$proof"
rm -rf "$install_dir"

key_dir="/root/.ssh"
mkdir -p "$key_dir"

age-keygen -pq -o "$key_dir/thislaptop-pq-key.txt" 2>/dev/null
age-keygen -y "$key_dir/thislaptop-pq-key.txt" > "$key_dir/thislaptop-pq.pub"
chmod 600 "$key_dir/thislaptop-pq-key.txt"

printf 'Private key: %s\nPublic key:  %s\n' \
  "$key_dir/thislaptop-pq-key.txt" \
  "$key_dir/thislaptop-pq.pub"
```

