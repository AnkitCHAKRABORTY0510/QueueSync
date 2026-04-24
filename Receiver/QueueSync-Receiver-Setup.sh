#!/usr/bin/env bash
# QueueSync Ubuntu Receiver Installer
# Engineer-grade setup script for Ubuntu Linux
# Creates dedicated queuesync user + SSH + rsync receiver environment

set -euo pipefail

APP_NAME="QueueSync Receiver"
APP_USER="queuesync"
APP_GROUP="queuesync"
BASE_DIR="/home/${APP_USER}"
INCOMING_DIR="${BASE_DIR}/Incoming"
FAILED_DIR="${BASE_DIR}/Failed"
LOG_DIR="${BASE_DIR}/Logs"
SSH_PORT="22"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }
section() { echo; echo "==================================================="; echo "$1"; echo "==================================================="; }

trap 'error "Setup failed at line $LINENO"; exit 1' ERR

# ---------------------------------------------------
# PRECHECKS
# ---------------------------------------------------

section "QueueSync Ubuntu Receiver Installer"

if [[ $EUID -ne 0 ]]; then
    error "Run this script with sudo:"
    echo "sudo bash install_queuesync_receiver.sh"
    exit 1
fi

if [[ ! -f /etc/os-release ]]; then
    error "Cannot detect OS."
    exit 1
fi

source /etc/os-release

if [[ "${ID:-}" != "ubuntu" && "${ID_LIKE:-}" != *"ubuntu"* ]]; then
    warn "This script is optimized for Ubuntu."
    read -rp "Continue anyway? (y/N): " ans
    [[ "$ans" =~ ^[Yy]$ ]] || exit 1
fi

FREE_GB=$(df -BG / | awk 'NR==2 {gsub("G","",$4); print $4}')
if [[ "$FREE_GB" -lt 2 ]]; then
    warn "Low disk space detected: ${FREE_GB}GB free."
fi

info "OS: ${PRETTY_NAME:-Unknown}"
info "Free Space: ${FREE_GB}GB"

# ---------------------------------------------------
# NETWORK CHECK
# ---------------------------------------------------

section "Checking Network"

if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    info "Internet connectivity OK"
else
    warn "No internet connectivity. apt may fail if packages are missing."
fi

# ---------------------------------------------------
# PACKAGE INSTALL
# ---------------------------------------------------

section "Installing Required Packages"

export DEBIAN_FRONTEND=noninteractive

apt update -y
apt install -y openssh-server rsync ufw avahi-daemon curl

info "Packages installed"

# ---------------------------------------------------
# USER SETUP
# ---------------------------------------------------

section "Creating Dedicated QueueSync User"

if id "$APP_USER" >/dev/null 2>&1; then
    warn "User '$APP_USER' already exists."

    read -rp "Reuse existing user? (Y/n): " reuse
    if [[ "$reuse" =~ ^[Nn]$ ]]; then
        error "Please remove existing user manually or edit script."
        exit 1
    fi
else
    adduser --disabled-password --gecos "" "$APP_USER"
    info "User '$APP_USER' created"

    read -rsp "Set password for ${APP_USER}: " USER_PASS
    echo
    echo "${APP_USER}:${USER_PASS}" | chpasswd
    info "Password configured"
fi

# ---------------------------------------------------
# DIRECTORY STRUCTURE
# ---------------------------------------------------

section "Creating Folder Structure"

mkdir -p "$INCOMING_DIR"
mkdir -p "$FAILED_DIR"
mkdir -p "$LOG_DIR"
mkdir -p "${BASE_DIR}/.ssh"

chown -R "${APP_USER}:${APP_GROUP}" "$BASE_DIR"
chmod 700 "${BASE_DIR}/.ssh"
chmod 755 "$INCOMING_DIR"
chmod 755 "$FAILED_DIR"
chmod 755 "$LOG_DIR"

info "Directories ready"

# ---------------------------------------------------
# SSH SERVICE
# ---------------------------------------------------

section "Configuring SSH"

systemctl enable ssh
systemctl restart ssh

if systemctl is-active ssh >/dev/null 2>&1; then
    info "SSH service running"
else
    error "SSH service failed"
    exit 1
fi

# ---------------------------------------------------
# FIREWALL
# ---------------------------------------------------

section "Firewall Configuration"

ufw allow "${SSH_PORT}/tcp" >/dev/null 2>&1 || true

if ufw status | grep -q inactive; then
    warn "UFW firewall inactive (acceptable)"
else
    info "Firewall active, SSH allowed"
fi

# ---------------------------------------------------
# HOSTNAME DISCOVERY
# ---------------------------------------------------

section "Hostname / LAN Discovery"

CURRENT_HOST=$(hostname)
IP_ADDR=$(hostname -I | awk '{print $1}')

info "Hostname: $CURRENT_HOST"
info "IP Address: $IP_ADDR"

# ---------------------------------------------------
# SELF TESTS
# ---------------------------------------------------

section "Running Diagnostics"

if command -v rsync >/dev/null 2>&1; then
    info "rsync installed"
else
    error "rsync missing"
fi

if command -v ssh >/dev/null 2>&1; then
    info "ssh client installed"
fi

if su - "$APP_USER" -c "touch ${INCOMING_DIR}/.write_test && rm ${INCOMING_DIR}/.write_test"; then
    info "queuesync user can write to Incoming folder"
else
    error "Write test failed"
fi

# ---------------------------------------------------
# OPTIONAL SSH KEY SETUP MESSAGE
# ---------------------------------------------------

section "Recommended Next Step"

echo "From your Mac, run:"
echo
echo "ssh-copy-id ${APP_USER}@${IP_ADDR}"
echo
echo "This enables passwordless secure login."

# ---------------------------------------------------
# SUMMARY
# ---------------------------------------------------

section "QueueSync Receiver Setup Complete"

echo "App User        : ${APP_USER}"
echo "Host            : ${CURRENT_HOST}"
echo "IP Address      : ${IP_ADDR}"
echo "SSH Port        : ${SSH_PORT}"
echo "Incoming Folder : ${INCOMING_DIR}"
echo "Logs Folder     : ${LOG_DIR}"
echo

echo "Test from Mac:"
echo "ssh ${APP_USER}@${IP_ADDR}"
echo
echo "Send file:"
echo "rsync -avz test.txt ${APP_USER}@${IP_ADDR}:${INCOMING_DIR}/"
echo

info "Setup completed successfully."
