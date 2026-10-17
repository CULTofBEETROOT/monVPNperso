#!/usr/bin/env bash
set -euo pipefail

key_dir="$HOME/.ssh"
mkdir -p "$key_dir"
chmod 700 "$key_dir"

stamp="$(date '+%Y-%m-%d-%H-%M-%S')"
key_path="$key_dir/vps4wireguard-$stamp"
comment="vps4wireguard-$stamp"

ssh-keygen -q -t ed25519 -a 100 \
  -f "$key_path" \
  -C "$comment"

eval "$(ssh-agent -s)"
ssh-add "$key_path"

cat >> "$key_dir/config" <<EOF

Host vps4wireguard
    HostName YourVPSip
    User root
    Port 22
    IdentityFile "$key_path"
    IdentitiesOnly yes
EOF

chmod 600 "$key_dir/config"

printf 'Private key: %s\nPublic key:  %s.pub\n' "$key_path" "$key_path"
