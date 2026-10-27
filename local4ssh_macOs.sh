#!/usr/bin/env bash
set -euo pipefail

key_dir="$HOME/.ssh"
config="$key_dir/config"

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

pubkey="$(ssh-keygen -y -f "$key_path")"
sed -i '' "s|METTEZ_VOTRE_CLEF_PUBLIQUE_ICI|$pubkey|g" "$key_dir/install_vpn_ON_vps.sh"
read -r -p "VPS public IP or DNS name: " VPS_ENDPOINTfeeder
sed -i '' "s|VPS_ENDPOINT|$VPS_ENDPOINTfeeder|g" "$key_dir/install_vpn_ON_vps.sh"
touch "$config"
cat >> "$config" <<EOF

Host vps4wireguard
    HostName YourVPSip
    User root
    Port 22
    IdentityFile "$key_path"
    IdentitiesOnly yes
EOF

chmod 600 "$config"

printf 'Private key: %s\nPublic key:  %s.pub\n' "$key_path" "$key_path"
