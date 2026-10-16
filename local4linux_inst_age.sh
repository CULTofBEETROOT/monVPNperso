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
