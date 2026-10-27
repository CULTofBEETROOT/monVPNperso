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
sed -i '' "s||METTEZ_VOTRE_CLEF_AGE_ICI|$(cat "$key_dir/thislaptop-pq.pub")|" "$HOME/Desktop/install_vpn_ON_vps.sh"
chmod 600 "$key_dir/thislaptop-pq-key.txt"

printf 'Private key: %s\nPublic key:  %s\n' \
  "$key_dir/thislaptop-pq-key.txt" \
  "$key_dir/thislaptop-pq.pub"
