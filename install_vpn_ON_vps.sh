#!/usr/bin/env bash
HISTCONTROL=ignoreboth

 if [[ $(cat /etc/hosts | grep $(hostname) | grep 127.0.1.1) == "" ]]; then
    echo "127.0.1.1    $(hostname)" >>  /etc/hosts;
 fi

rm -f /etc/apt/*.list
rm -f /etc/apt/*.list~
rm -R /etc/apt/*.list.d
cat>/etc/apt/sources.list<<'endletsapt'
deb https://deb.debian.org/debian/ trixie main contrib non-free-firmware
deb https://security.debian.org/debian-security/ trixie-security main contrib non-free-firmware
deb https://deb.debian.org/debian/ trixie-updates main contrib non-free-firmware
endletsapt

 apt update 
 apt install -y sudo;
 apt install -y tor apt-transport-tor
 systemctl enable --now tor.service

echo "transport-tor downloaded"
echo "TorNodes {ch}" > /etc/tor/torrc
echo "StrictNodes 1" >> /etc/tor/torrc
rm -f /etc/apt/sources.list
mkdir -p /etc/apt/sources.list.d
touch /etc/apt/sources.list.d/debian.sources
cat>/etc/apt/sources.list.d/debian.sources<<'endupdateapt'
# Modernized from /etc/apt/sources.list
Types: deb
URIs: tor+https://deb.debian.org/debian/
Suites: trixie
Components: main contrib non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

# Modernized from /etc/apt/sources.list
Types: deb
URIs: tor+https://security.debian.org/debian-security/
Suites: trixie-security
Components: main contrib non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

# Modernized from /etc/apt/sources.list
Types: deb
URIs: tor+https://deb.debian.org/debian/
Suites: trixie-updates
Components: main contrib non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
endupdateapt

rm -f /etc/apt/*.list
rm -f /etc/apt/*.list~
apt update
apt upgrade -y
apt autoremove -y ufw
apt install -y ufw
sudo ufw allow in 22/tcp
sudo ufw enable
    apt-get install -y --no-install-recommends \
        openssh-server \
        sudo \
        ufw \
        wireguard \
        wireguard-tools \
        qrencode \
        nftables \
        curl \
	torsocks \
        jq \
        dnsutils \
        grep \
        sed \
        coreutils \
        findutils \
        procps \
        gawk \
        util-linux \
        gnupg \
        openssl \
        clamav \
        clamav-daemon \
        clamav-freshclam \
	tar \
	golang-go \
	git
apt autoremove -y

mkdir -p /home/$USER/install_wg100clients/functions
mkdir -p /home/$USER/install_wg100clients/updater
cd /home/$USER/install_wg100clients

cat>/home/$USER/install_wg100clients/config.sh<<'njroegjorenjgoer'
#!/usr/bin/env bash

SSH_USER="vpnadmin"
SSH_PORT="61588"
SSH_PUBLIC_KEY='METTEZ_VOTRE_CLEF_PUBLIQUE_ICI'
AGEPQ_destpub='METTEZ_VOTRE_CLEF_AGE_ICI'

WG_IF="wg0"
WG_DIR="/etc/wireguard"
WG_PORT="51820"
VPN_NET="10.66.66.0/24"
SERVER_ADDRESS="10.66.66.1/24"
DNS_SERVER="1.1.1.1"
KEEPALIVE="40"

CLIENT_COUNT="100"
CLIENT_PREFIX="client"
CLIENT_DIR="/root/wireguard-clients"

NFT_FAMILY="inet"
NFT_TABLE="wg_adult_block"
NFT_CHAIN="forward"
NFT_SET4="porn_ipv4"
NFT_SET6="porn_ipv6"

INSTALL_DIR="/opt/bon-appetit-porn-blocker"
UPDATE_SCRIPT="${INSTALL_DIR}/update.sh"

UPDATER_SOURCE="${SCRIPT_DIR}/updater/update.sh"

VPS_ENDPOINT=""
WAN_IF=""
SSH_HOME=""
SSH_DIR=""
AUTHORIZED_KEYS=""
SERVER_PRIVATE=""
SERVER_PUBLIC=""
SERVER_CONF=""
GPG_PASSPHRASE=""
GPG_PASSFILE=""

njroegjorenjgoer


cat>/home/$USER/install_wg100clients/functions/cleanup.sh<<'welfkgunsegkjlbsjkler'
#!/usr/bin/env bash

cleanup_installer_temp_files() {
    if [[ -n "${GPG_PASSFILE:-}" && -f "${GPG_PASSFILE}" ]]; then
        shred -u "${GPG_PASSFILE}" 2>/dev/null ||
            rm -f "${GPG_PASSFILE}"
    fi
}
welfkgunsegkjlbsjkler



cat>/home/$USER/install_wg100clients/functions/validation.sh<<'alasidgnsemngbkvhjihcwj'
#!/usr/bin/env bash

validate_installer_configuration() {
    [[ "${EUID}" -eq 0 ]] || {
        echo "Run this script as root." >&2
        exit 1
    }

    command -v apt-get >/dev/null 2>&1 || {
        echo "Debian or Ubuntu required." >&2
        exit 1
    }

    [[ "${SSH_USER}" != "root" ]] || {
        echo "SSH_USER must not be root." >&2
        exit 1
    }

    [[ "${SSH_USER}" =~ ^[a-z_][a-z0-9_-]*$ ]] || {
        echo "Invalid SSH username." >&2
        exit 1
    }

    [[ "${SSH_PORT}" =~ ^[0-9]+$ ]] &&
        (( SSH_PORT >= 1 && SSH_PORT <= 65535 )) || {
        echo "Invalid SSH port." >&2
        exit 1
    }

    [[ "${WG_PORT}" =~ ^[0-9]+$ ]] &&
        (( WG_PORT >= 1 && WG_PORT <= 65535 )) || {
        echo "Invalid WireGuard port." >&2
        exit 1
    }

    [[ "${CLIENT_COUNT}" =~ ^[0-9]+$ ]] &&
        (( CLIENT_COUNT >= 1 && CLIENT_COUNT <= 253 )) || {
        echo "CLIENT_COUNT must be between 1 and 253." >&2
        exit 1
    }

    [[ "${SSH_PUBLIC_KEY}" =~ ^ssh-ed25519[[:space:]]+[^[:space:]]+([[:space:]].*)?$ ]] || {
        echo "SSH_PUBLIC_KEY must contain an Ed25519 public key." >&2
        exit 1
    }

    [[ "${SSH_PUBLIC_KEY}" != *REPLACE_WITH_YOUR_PUBLIC_KEY* ]] || {
        echo "Replace SSH_PUBLIC_KEY with your real Ed25519 public key." >&2
        exit 1
    }

    read -r -p "VPS public IP or DNS name: " VPS_ENDPOINT

    [[ -n "${VPS_ENDPOINT}" ]] || {
        echo "A VPS public IP or DNS name is required." >&2
        exit 1
    }

    WAN_IF="$(ip route show default | awk 'NR == 1 {print $5}')"

    [[ -n "${WAN_IF}" ]] || {
        echo "Could not detect the WAN interface." >&2
        exit 1
    }

    echo "Detected WAN interface: ${WAN_IF}"
}

alasidgnsemngbkvhjihcwj


cat>/home/$USER/install_wg100clients/functions/packages.sh<<'dfkljdbnesnfjvhdsbestjr'
#!/usr/bin/env bash

install_required_packages() {
    echo "[1/13] Installing packages..."

    export DEBIAN_FRONTEND=noninteractive

    apt-get update
    apt-get install -y --no-install-recommends \
        openssh-server \
        sudo \
        ufw \
        wireguard \
        wireguard-tools \
        qrencode \
        nftables \
        curl \
        jq \
        dnsutils \
        grep \
        sed \
        coreutils \
        findutils \
        procps \
        gawk \
        util-linux \
        gnupg \
        openssl \
        clamav \
        clamav-daemon \
	git \
        clamav-freshclam
}


dfkljdbnesnfjvhdsbestjr


cat>/home/$USER/install_wg100clients/functions/agePQ.sh<<'dfkljdbnmgcmdg58esnfjvhdsbestjr'
#!/usr/bin/env bash
set -euo pipefail

apt install -y tar golang-go torsocks curl git

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

key_dir="$HOME/.ssh"
mkdir -p "$key_dir"

age-keygen -pq -o "$key_dir/is33-pq-key.txt" 2>/dev/null
age-keygen -y "$key_dir/is33-pq-key.txt" > "$key_dir/is33-pq.pub"
chmod 600 "$key_dir/is33-pq-key.txt"

printf 'Private key: %s\nPublic key:  %s\n' \
  "$key_dir/is33-pq-key.txt" \
  "$key_dir/is33-pq.pub"

dfkljdbnmgcmdg58esnfjvhdsbestjr



cat>/home/$USER/install_wg100clients/functions/ssh-user.sh<<'lkdvknekjrvbklresj'
#!/usr/bin/env bash

configure_ssh_user() {
    echo "[2/13] Configuring non-root SSH user..."

    if id "${SSH_USER}" >/dev/null 2>&1; then
        usermod --shell /bin/bash "${SSH_USER}"
    else
        useradd \
            --create-home \
            --shell /bin/bash \
            "${SSH_USER}"
    fi

    usermod --append --groups sudo "${SSH_USER}"

    SSH_HOME="$(getent passwd "${SSH_USER}" | cut -d: -f6)"
    SSH_DIR="${SSH_HOME}/.ssh"
    AUTHORIZED_KEYS="${SSH_DIR}/authorized_keys"

    [[ -n "${SSH_HOME}" && -d "${SSH_HOME}" ]] || {
        echo "Could not determine the home directory for ${SSH_USER}." >&2
        exit 1
    }

    install -d \
        -o "${SSH_USER}" \
        -g "${SSH_USER}" \
        -m 700 \
        "${SSH_DIR}"

    printf '%s\n' "${SSH_PUBLIC_KEY}" > "${AUTHORIZED_KEYS}"

    chown "${SSH_USER}:${SSH_USER}" "${AUTHORIZED_KEYS}"
    chmod 600 "${AUTHORIZED_KEYS}"

    echo
    echo "Set a password for ${SSH_USER}."
    echo "This password is used by sudo; SSH password authentication remains disabled."
    passwd "${SSH_USER}"
}

lkdvknekjrvbklresj




cat>/home/$USER/install_wg100clients/functions/ssh-hardening.sh<<'ivergjkyvbaqwesvbkjhrksw'
#!/usr/bin/env bash

configure_ssh_hardening() {
    echo "[3/13] Configuring SSH on port ${SSH_PORT}..."

    install -d -m 755 /etc/ssh/sshd_config.d

    local config_file="/etc/ssh/sshd_config.d/99-key-only-non-root.conf"
    local backup_file="/etc/ssh/sshd_config.bon-appetit-backup"

    if [[ ! -f "${backup_file}" ]]; then
        cp -a /etc/ssh/sshd_config "${backup_file}"
    fi

    if ! grep -Eq '^[[:space:]]*Include[[:space:]]+/etc/ssh/sshd_config\.d/\*\.conf([[:space:]]|$)' /etc/ssh/sshd_config; then
        sed -i '1i Include /etc/ssh/sshd_config.d/*.conf' /etc/ssh/sshd_config
    fi

    sed -ri \
        's/^[[:space:]]*#?[[:space:]]*Port[[:space:]]+[0-9]+/# Disabled by installer: &/' \
    /etc/ssh/sshd_config


    cat > "${config_file}" <<EOF
Port ${SSH_PORT}
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
AuthenticationMethods publickey
#PermitRootLogin no
PermitRootLogin yes
PermitEmptyPasswords no
UsePAM yes
AllowUsers ${SSH_USER} root
EOF

    chmod 644 "${config_file}"

    sshd -t
}

ivergjkyvbaqwesvbkjhrksw



cat>/home/$USER/install_wg100clients/functions/ufw.sh<<'lkfbtdhkghvhebhvcjvjbser'
#!/usr/bin/env bash

configure_ufw_firewall() {
    echo "[4/13] Configuring UFW..."

    ufw --force reset

    ufw default deny incoming
    ufw default allow outgoing
    ufw default deny routed

    ufw allow in on "${WAN_IF}" \
        proto tcp \
        to any port "${SSH_PORT}" \
        comment "SSH administration"

    ufw allow in on "${WAN_IF}" \
        proto udp \
        to any port "${WG_PORT}" \
        comment "WireGuard"

    ufw route allow in on "${WG_IF}" out on "${WAN_IF}" \
        from "${VPN_NET}" to any port 53 proto udp \
        comment "VPN DNS UDP"

    ufw route allow in on "${WG_IF}" out on "${WAN_IF}" \
        from "${VPN_NET}" to any port 53 proto tcp \
        comment "VPN DNS TCP"

    ufw route allow in on "${WG_IF}" out on "${WAN_IF}" \
        from "${VPN_NET}" to any port 80 proto tcp \
        comment "VPN HTTP"

    ufw route allow in on "${WG_IF}" out on "${WAN_IF}" \
        from "${VPN_NET}" to any port 443 proto tcp \
        comment "VPN HTTPS"

    ufw route allow in on "${WG_IF}" out on "${WAN_IF}" \
        from "${VPN_NET}" to any port 443 proto udp \
        comment "VPN QUIC"

    local nat_rule="-A POSTROUTING -s ${VPN_NET} -o ${WAN_IF} -j MASQUERADE"

    if ! grep -qF -- "${nat_rule}" /etc/ufw/before.rules; then
        local temporary_rules
        temporary_rules="$(mktemp)"

        awk \
            -v vpn_net="${VPN_NET}" \
            -v wan_if="${WAN_IF}" '
            BEGIN { inserted = 0 }
            /^\*filter/ && inserted == 0 {
                print "*nat"
                print ":POSTROUTING ACCEPT [0:0]"
                print "-A POSTROUTING -s " vpn_net " -o " wan_if " -j MASQUERADE"
                print "COMMIT"
                print ""
                inserted = 1
            }
            { print }
        ' /etc/ufw/before.rules > "${temporary_rules}"

        install -m 644 "${temporary_rules}" /etc/ufw/before.rules
        rm -f "${temporary_rules}"
    fi

    ufw --force enable
}


lkfbtdhkghvhebhvcjvjbser





cat>/home/$USER/install_wg100clients/functions/ssh-service.sh<<'hbfvkbsrenjlbkkhfbwnkdf'
#!/usr/bin/env bash

restart_ssh_service() {
    echo "[5/13] Restarting SSH..."

    if systemctl is-active --quiet ssh.service; then
        systemctl reload ssh.service
    elif systemctl is-active --quiet sshd.service; then
        systemctl reload sshd.service
    else
        systemctl enable --now ssh.service 2>/dev/null ||
            systemctl enable --now sshd.service
    fi
}

hbfvkbsrenjlbkkhfbwnkdf


cat>/home/$USER/install_wg100clients/functions/nftables.sh<<'njfeuirkdvbekuvhj'
#!/usr/bin/env bash

configure_nftables_blocking_table() {
    echo "[6/13] Preparing nftables..."

    nft list table "${NFT_FAMILY}" "${NFT_TABLE}" >/dev/null 2>&1 ||
        nft add table "${NFT_FAMILY}" "${NFT_TABLE}"

    nft list set "${NFT_FAMILY}" "${NFT_TABLE}" "${NFT_SET4}" >/dev/null 2>&1 ||
        nft add set "${NFT_FAMILY}" "${NFT_TABLE}" "${NFT_SET4}" \
            '{ type ipv4_addr; flags interval; }'

    nft list set "${NFT_FAMILY}" "${NFT_TABLE}" "${NFT_SET6}" >/dev/null 2>&1 ||
        nft add set "${NFT_FAMILY}" "${NFT_TABLE}" "${NFT_SET6}" \
            '{ type ipv6_addr; flags interval; }'

    nft list chain "${NFT_FAMILY}" "${NFT_TABLE}" "${NFT_CHAIN}" >/dev/null 2>&1 ||
        nft add chain "${NFT_FAMILY}" "${NFT_TABLE}" "${NFT_CHAIN}" \
            '{ type filter hook forward priority filter; policy accept; }'

    nft -a list chain "${NFT_FAMILY}" "${NFT_TABLE}" "${NFT_CHAIN}" |
        grep -Fq "iifname \"${WG_IF}\" ip daddr @${NFT_SET4}" ||
        nft add rule "${NFT_FAMILY}" "${NFT_TABLE}" "${NFT_CHAIN}" \
            iifname "${WG_IF}" ip daddr "@${NFT_SET4}" counter drop

    nft -a list chain "${NFT_FAMILY}" "${NFT_TABLE}" "${NFT_CHAIN}" |
        grep -Fq "iifname \"${WG_IF}\" ip6 daddr @${NFT_SET6}" ||
        nft add rule "${NFT_FAMILY}" "${NFT_TABLE}" "${NFT_CHAIN}" \
            iifname "${WG_IF}" ip6 daddr "@${NFT_SET6}" counter drop
}

njfeuirkdvbekuvhj



cat>/home/$USER/install_wg100clients/functions/updater-installation.sh<<'kdfnjrehiouje'
#!/usr/bin/env bash

install_domain_list_updater() {
    echo "[7/13] Installing domain-list updater..."

    [[ -f "${UPDATER_SOURCE}" ]] || {
        echo "Updater source not found: ${UPDATER_SOURCE}" >&2
        exit 1
    }

    install -d -m 700 "${INSTALL_DIR}"
    install -m 700 "${UPDATER_SOURCE}" "${UPDATE_SCRIPT}"
}

kdfnjrehiouje



cat>/home/$USER/install_wg100clients/functions/wireguard.sh<<'noifubernldhsksgdyvfhjew'
configure_wireguard_server_and_clients() {
    echo "[8/13] Configuring WireGuard..."

    systemctl disable --now "wg-quick@${WG_IF}" 2>/dev/null || true
    wg-quick down "${WG_IF}" 2>/dev/null || true
    ip link delete "${WG_IF}" 2>/dev/null || true

    if [[ -d "${WG_DIR}" ]]; then
        mv "${WG_DIR}" "${WG_DIR}.bon-appetit-backup.$(date +%s)" || return 1
    fi

    if [[ -d "${CLIENT_DIR}" ]]; then
        mv "${CLIENT_DIR}" "${CLIENT_DIR}.bon-appetit-backup.$(date +%s)" || return 1
    fi

    install -d -m 700 "${WG_DIR}" "${CLIENT_DIR}" || return 1

    local old_umask
    old_umask="$(umask)"
    umask 077

    local server_private server_public
    server_private="$(wg genkey)" || return 1
    server_public="$(printf '%s\n' "${server_private}" | wg pubkey)" || return 1

    printf '%s\n' "${server_private}" > "${WG_DIR}/server.key" || return 1
    printf '%s\n' "${server_public}" > "${WG_DIR}/server.pub" || return 1

    SERVER_PRIVATE="${server_private}"
    SERVER_PUBLIC="${server_public}"
    SERVER_CONF="${WG_DIR}/${WG_IF}.conf"

    cat > "${SERVER_CONF}" <<EOF
[Interface]
Address = ${SERVER_ADDRESS}
ListenPort = ${WG_PORT}
PrivateKey = ${SERVER_PRIVATE}
EOF
    [[ $? -eq 0 ]] || return 1

    emit_client_conf() {
        local private_key="$1"
        local address="$2"

        printf '%s\n' \
            '[Interface]' \
            "PrivateKey = ${private_key}" \
            "Address = ${address}" \
            "DNS = ${DNS_SERVER}" \
            '' \
            '[Peer]' \
            "PublicKey = ${SERVER_PUBLIC}" \
            "Endpoint = ${VPS_ENDPOINT}:${WG_PORT}" \
            'AllowedIPs = 0.0.0.0/0' \
            "PersistentKeepalive = ${KEEPALIVE}"
    }

    local client_number client_name client_ip client_address
    local client_private client_public client_conf_age client_qr_age

    for client_number in $(seq 1 "${CLIENT_COUNT}"); do
        client_name="${CLIENT_PREFIX}${client_number}"
        client_ip="10.66.66.$((client_number + 1))"
        client_address="${client_ip}/32"

        # Keep client keys in shell variables; do not write them to key files.
        client_private="$(wg genkey)" || return 1
        client_public="$(printf '%s\n' "${client_private}" | wg pubkey)" || return 1

        cat >> "${SERVER_CONF}" <<EOF

[Peer]
# ${client_name}
PublicKey = ${client_public}
AllowedIPs = ${client_address}
EOF
        [[ $? -eq 0 ]] || return 1

        client_conf_age="${CLIENT_DIR}/${client_name}.conf.age"
        client_qr_age="${CLIENT_DIR}/${client_name}.png.age"

        # Encrypt the config text directly; do not create a plaintext .conf file.
        if ! (
            set -o pipefail
            emit_client_conf "${client_private}" "${client_address}" |
                age -r "${AGEPQ_destpub}" -o "${client_conf_age}"
        ); then
            return 1
        fi

        # Stream the config through qrencode, then encrypt the PNG output.
        if ! (
            set -o pipefail
            emit_client_conf "${client_private}" "${client_address}" |
                qrencode -t PNG -o - |
                age -r "${AGEPQ_destpub}" -o "${client_qr_age}"
        ); then
            return 1
        fi

        chmod 600 "${client_conf_age}" "${client_qr_age}" || return 1
        echo "Created encrypted ${client_name} files for ${client_ip}"
    done

    chmod 600 \
        "${SERVER_CONF}" \
        "${WG_DIR}/server.key" \
        "${WG_DIR}/server.pub" || return 1

    umask "${old_umask}"
    echo "WireGuard configuration complete."
}

noifubernldhsksgdyvfhjew



cat>/home/$USER/install_wg100clients/functions/forwarding.sh<<'jfvbngwlirueskhnlwfhjs'
#!/usr/bin/env bash

enable_ipv4_forwarding() {
    echo "[9/13] Enabling IPv4 forwarding..."

    cat > /etc/sysctl.d/99-wireguard-forwarding.conf <<'EOF'
net.ipv4.ip_forward=1
EOF

    sysctl --system >/dev/null
}

jfvbngwlirueskhnlwfhjs




cat>/home/$USER/install_wg100clients/functions/systemd.sh<<'oisvbhej4krfddjvhesnfkher'
#!/usr/bin/env bash

install_systemd_services() {
    echo "[10/13] Installing systemd services..."

    cat > /etc/systemd/system/bon-appetit-porn-blocker.service <<EOF
[Unit]
Description=Bon-Appetit domain IP blocker
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=${UPDATE_SCRIPT}
TimeoutStartSec=infinity
StandardOutput=journal
StandardError=journal
EOF

    cat>/etc/systemd/system/bon-appetit-porn-blocker.timer<<'EOF'
[Unit]
Description=Update Bon-Appetit domain IP blocker

[Timer]
OnBootSec=10min
OnUnitActiveSec=6h
Persistent=true

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
}

oisvbhej4krfddjvhesnfkher



cat>/home/$USER/install_wg100clients/functions/clamav.sh<<'jkfnsekjfhjfhksedrtkhbenwl3fukjesr'
#!/usr/bin/env bash

configure_clamav_services() {
    echo "[11/13] Configuring ClamAV..."

    systemctl enable --now clamav-daemon.service 2>/dev/null || true
    systemctl enable --now clamav-freshclam.service 2>/dev/null || true
}


jkfnsekjfhjfhksedrtkhbenwl3fukjesr


cat>/home/$USER/install_wg100clients/functions/services.sh<<'khdfbkesgfdxjhfwhlershjss'
#!/usr/bin/env bash

enable_installed_services() {
    echo "[12/13] Enabling services..."

    systemctl enable --now "wg-quick@${WG_IF}"
    systemctl enable --now bon-appetit-porn-blocker.timer

    systemctl start bon-appetit-porn-blocker.service
}

khdfbkesgfdxjhfwhlershjss



cat>/home/$USER/install_wg100clients/functions/verification.sh<<'iuuserbnj3jfrvuicdafsewbnefsrdfhbew'
#!/usr/bin/env bash

verify_installation() {
    echo
    echo "Installation complete."
    echo
    echo "SSH:"
    echo "  User: ${SSH_USER}"
    echo "  Port: ${SSH_PORT}"
    echo "  Login:"
    echo "    ssh -i ~/.ssh/YOUR_PRIVATE_KEY -p ${SSH_PORT} ${SSH_USER}@${VPS_ENDPOINT}"
    echo
    echo "WireGuard server configuration:"
    echo "  ${SERVER_CONF}"
    echo
    echo "Encrypted client files:"
    echo "  ${CLIENT_DIR}/${CLIENT_PREFIX}*.conf.age"
    echo
    echo "Client-file decryption passphrase:"
    echo "  ${CLIENT_DIR}/${CLIENT_PREFIX}*.png.age"
    echo
    echo "Firewall:"
    ufw status verbose
    echo
    echo "WireGuard:"
    wg show "${WG_IF}"
    echo
    echo "nftables blocking table:"
    nft list table "${NFT_FAMILY}" "${NFT_TABLE}"
    echo
    echo "Updater timer:"
    systemctl status \
        bon-appetit-porn-blocker.timer \
        --no-pager
    echo
    echo "Important:"
    echo "  Test SSH from a second terminal before closing this session."
    echo "  SSH password authentication is disabled."
    echo "  The SSH user's password is used only for sudo."
}

iuuserbnj3jfrvuicdafsewbnefsrdfhbew


cat>/home/$USER/install_wg100clients/install2.sh<<'vgeiogbkdfewjggtfbjoghyghbnj'
#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 &&
    pwd
)"

source "${SCRIPT_DIR}/config.sh"

source "${SCRIPT_DIR}/functions/cleanup.sh"
source "${SCRIPT_DIR}/functions/validation.sh"
source "${SCRIPT_DIR}/functions/packages.sh"
source "${SCRIPT_DIR}/functions/ssh-user.sh"
source "${SCRIPT_DIR}/functions/ssh-hardening.sh"
source "${SCRIPT_DIR}/functions/ufw.sh"
source "${SCRIPT_DIR}/functions/ssh-service.sh"
source "${SCRIPT_DIR}/functions/nftables.sh"
source "${SCRIPT_DIR}/functions/updater-installation.sh"
source "${SCRIPT_DIR}/functions/wireguard.sh"
source "${SCRIPT_DIR}/functions/forwarding.sh"
source "${SCRIPT_DIR}/functions/systemd.sh"
source "${SCRIPT_DIR}/functions/clamav.sh"
source "${SCRIPT_DIR}/functions/services.sh"
source "${SCRIPT_DIR}/functions/verification.sh"

main() {
    trap cleanup_installer_temp_files EXIT

    validate_installer_configuration
    install_required_packages
    configure_ssh_user
    configure_ssh_hardening
    configure_ufw_firewall
    restart_ssh_service
    configure_nftables_blocking_table
    install_domain_list_updater
    configure_wireguard_server_and_clients
    enable_ipv4_forwarding
    install_systemd_services
    configure_clamav_services
    enable_installed_services
    verify_installation
}

main "$@"


vgeiogbkdfewjggtfbjoghyghbnj




cat>/home/$USER/install_wg100clients/updater/update.sh<<'adwgvq2ruerguivjkdehrwsfuidyuhjwb3jnew'
#!/usr/bin/env bash
set -Eeuo pipefail

UPDATER_FAMILY="inet"
UPDATER_TABLE="wg_adult_block"
UPDATER_SET4="porn_ipv4"
UPDATER_SET6="porn_ipv6"
UPDATER_PARALLEL_JOBS=32
UPDATER_API_URL="https://api.github.com/repos/Bon-Appetit/porn-domains/contents"
UPDATER_LOCK_FILE="/run/bon-appetit-porn-blocker.lock"

UPDATER_TMP_DIR=""

cleanup_updater_temp_files() {
    if [[ -n "${UPDATER_TMP_DIR}" && -d "${UPDATER_TMP_DIR}" ]]; then
        rm -rf "${UPDATER_TMP_DIR}"
    fi
}

log_updater_message() {
    printf '[%s] %s\n' "$(date '+%F %T')" "$*"
}

validate_updater_dependencies() {
    local required_command

    for required_command in curl jq awk sed sort wc tr xargs dig nft flock find; do
        command -v "${required_command}" >/dev/null 2>&1 || {
            log_updater_message "ERROR: Required command not found: ${required_command}"
            exit 1
        }
    done
}

download_updater_domain_list() {
    local domain_list_url

    log_updater_message "Downloading domain list..."

    domain_list_url="$(
        curl \
            --fail \
            --silent \
            --show-error \
            --location \
            --connect-timeout 10 \
            --max-time 60 \
            -H 'Accept: application/vnd.github+json' \
            "${UPDATER_API_URL}" |
            jq -r '
                .[] |
                select(.type=="file") |
                select(
                    (.name | ascii_downcase | contains("block")) and
                    (.name | ascii_downcase | endswith(".txt"))
                ) |
                .download_url
            ' |
            head -n1
    )"

    [[ -n "${domain_list_url}" && "${domain_list_url}" != "null" ]] || {
        log_updater_message "ERROR: Could not find the domain-list URL."
        exit 1
    }

    curl \
        --fail \
        --silent \
        --show-error \
        --location \
        --connect-timeout 10 \
        --max-time 120 \
        "${domain_list_url}" \
        -o "${UPDATER_TMP_DIR}/source"
}

extract_updater_domains() {
    awk '
        /^[[:space:]]*#/ || NF == 0 {
            next
        }

        {
            for (i = 1; i <= NF; i++) {
                if ($i ~ /^[A-Za-z0-9][A-Za-z0-9.-]*\.[A-Za-z]{2,}$/) {
                    print tolower($i)
                    break
                }
            }
        }
    ' "${UPDATER_TMP_DIR}/source" |
        sed 's/\.$//' |
        sort -u > "${UPDATER_TMP_DIR}/domains"

    local total
    total="$(wc -l < "${UPDATER_TMP_DIR}/domains" | tr -d ' ')"

    [[ "${total}" -gt 0 ]] || {
        log_updater_message "ERROR: Domain list is empty."
        exit 1
    }

    log_updater_message "Loaded ${total} domains."
}

resolve_updater_domain_addresses() {
    local total
    local resolver_pid
    local done_count

    total="$(wc -l < "${UPDATER_TMP_DIR}/domains" | tr -d ' ')"

    export UPDATER_TMP_DIR

    nl -ba "${UPDATER_TMP_DIR}/domains" |
        xargs -r -P "${UPDATER_PARALLEL_JOBS}" -n 2 bash -c '
            index="$1"
            domain="$2"

            dig +short +time=3 +tries=1 A "$domain" 2>/dev/null |
                grep -E "^[0-9]{1,3}(\.[0-9]{1,3}){3}$" |
                sort -u > "$UPDATER_TMP_DIR/v4.$index" || :

            dig +short +time=3 +tries=1 AAAA "$domain" 2>/dev/null |
                grep -E ":" |
                sort -u > "$UPDATER_TMP_DIR/v6.$index" || :

            : > "$UPDATER_TMP_DIR/done.$index"
        ' _ &

    resolver_pid=$!

    while kill -0 "${resolver_pid}" 2>/dev/null; do
        done_count="$(
            find "${UPDATER_TMP_DIR}" \
                -maxdepth 1 \
                -type f \
                -name 'done.*' |
                wc -l |
                tr -d ' '
        )"

        log_updater_message "DNS progress: ${done_count}/${total}"
        sleep 5
    done

    wait "${resolver_pid}"

    cat "${UPDATER_TMP_DIR}"/v4.* 2>/dev/null |
        sort -u > "${UPDATER_TMP_DIR}/ipv4" || :

    cat "${UPDATER_TMP_DIR}"/v6.* 2>/dev/null |
        sort -u > "${UPDATER_TMP_DIR}/ipv6" || :

    local v4_count
    local v6_count

    v4_count="$(wc -l < "${UPDATER_TMP_DIR}/ipv4" | tr -d ' ')"
    v6_count="$(wc -l < "${UPDATER_TMP_DIR}/ipv6" | tr -d ' ')"

    log_updater_message \
        "Resolved ${v4_count} IPv4 addresses and ${v6_count} IPv6 addresses."

    [[ -s "${UPDATER_TMP_DIR}/ipv4" || -s "${UPDATER_TMP_DIR}/ipv6" ]] || {
        log_updater_message \
            "ERROR: No addresses resolved. Existing sets were preserved."
        exit 1
    }
}

replace_updater_nftables_sets() {
    local -a ipv4_addresses=()
    local -a ipv6_addresses=()

    mapfile -t ipv4_addresses < "${UPDATER_TMP_DIR}/ipv4"
    mapfile -t ipv6_addresses < "${UPDATER_TMP_DIR}/ipv6"

    nft flush set \
        "${UPDATER_FAMILY}" \
        "${UPDATER_TABLE}" \
        "${UPDATER_SET4}"

    nft flush set \
        "${UPDATER_FAMILY}" \
        "${UPDATER_TABLE}" \
        "${UPDATER_SET6}"

    if (( ${#ipv4_addresses[@]} > 0 )); then
        nft add element \
            "${UPDATER_FAMILY}" \
            "${UPDATER_TABLE}" \
            "${UPDATER_SET4}" \
            "{ ${ipv4_addresses[*]} }"
    fi

    if (( ${#ipv6_addresses[@]} > 0 )); then
        nft add element \
            "${UPDATER_FAMILY}" \
            "${UPDATER_TABLE}" \
            "${UPDATER_SET6}" \
            "{ ${ipv6_addresses[*]} }"
    fi
}

main() {
    validate_updater_dependencies

    UPDATER_TMP_DIR="$(mktemp -d)"
    trap cleanup_updater_temp_files EXIT

    exec 9>"${UPDATER_LOCK_FILE}"

    flock -n 9 || {
        log_updater_message "Another update is already running."
        exit 0
    }

    download_updater_domain_list
    extract_updater_domains
    resolve_updater_domain_addresses
    replace_updater_nftables_sets

    log_updater_message "Domain-blocking update completed successfully."
}

main "$@"


adwgvq2ruerguivjkdehrwsfuidyuhjwb3jnew


chmod 700 install2.sh updater/update.sh
chmod 600 config.sh functions/*.sh


bash -n install2.sh
bash -n config.sh
for file in functions/*.sh updater/update.sh; do
    bash -n "$file"
done



bash functions/agePQ.sh

sudo bash install2.sh
echo "Port 61588" >> /etc/ssh/sshd_config
mv /root/wireguard-clients/*.age ../home/vpnadmin/
chmod 777 /home/vpnadmin/*.age
sudo systemctl restart ssh
