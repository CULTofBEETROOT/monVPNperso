#!/bin/bash

ssh-keygen -q -t ed25519 -a 100 \
	  -f "/root/.ssh/vps4wireguard-$(date '+%Y-%m-%d-%H-%M-%S')" \
	  -N "YouPassword" \
	  -C "vps4wireguard-$(date '+%Y-%m-%d-%H-%M-%S')"

eval "$(ssh-agent -s)"; \
key=$(printf '%s\n' /root/.ssh/vps4wireguard-* 2>/dev/null | grep -F -e "$(date +%F)" -e "$(date -d yesterday +%F)" | grep -v '\.pub$' | sort -r | head -n 1); \
[ -n "$key" ] && ssh-add "$key"

sed -i "s|METTEZ_VOTRE_CLEF_PUBLIQUE_ICI|$(ssh-keygen -y -f "$key")|g" /root/scripts/install_vpn_ON_vps.sh
read -r -p "VPS public IP or DNS name: " VPS_ENDPOINTfeeder
sed -i "s|VPS_ENDPOINT|$VPS_ENDPOINTfeeder|g" /root/scripts/install_vpn_ON_vps.sh
touch /root/.ssh/config
cat>>/root/.ssh/config<<"endsshlocalconfig"
	Host "vps4wireguard"
		HostName "$VPS_ENDPOINTfeeder"
		User root
		Port 22
		IdentityFile "vps4wireguard-$(date '+%Y-%m-%d-%H-%M-%S')"
		IdentitiesOnly yes
endsshlocalconfig
