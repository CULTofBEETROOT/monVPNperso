#!/bin/bash

ssh-keygen -q -t ed25519 -a 100 \
	  -f "/root/.ssh/vps4wireguard-$(date '+%Y-%m-%d-%H-%M-%S')" \
	  -N "YouPassword" \
	  -C "vps4wireguard-$(date '+%Y-%m-%d-%H-%M-%S')"

eval "$(ssh-agent -s)" \
ssh-add /root/.ssh/vps4wireguard-$(date '+%Y-%m-%d')*

touch /root/.ssh/config
cat>>/root/.ssh/config<<"endsshlocalconfig"
	Host "vps4wireguard"
		HostName "YourVPSip"
		User root
		Port 22
		IdentityFile "vps4wireguard-$(date '+%Y-%m-%d-%H-%M-%S')"
		IdentitiesOnly yes
endsshlocalconfig
