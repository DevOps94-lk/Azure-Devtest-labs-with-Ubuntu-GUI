#!/bin/bash
set -euo pipefail

# ------------------------------------------------------------------------------
# XRDP + XFCE Desktop Environment Setup Script for Ubuntu VMs
#
# PURPOSE:
# This script sets up a remote-accessible Ubuntu VM with a lightweight GUI 
# (XFCE) and XRDP for Remote Desktop Protocol access. It's designed for 
# development environments, remote labs, or cloud VMs that need GUI access.
#
# It also disables all sleep/suspend modes to ensure the VM stays awake
# and accessible via RDP at all times.
#
# WHAT THIS SCRIPT DOES:
# 1. Updates the system's package index.
# 2. Installs the XFCE4 desktop environment and session manager.
# 3. Installs XRDP for remote desktop access.
# 4. Enables XRDP to start at system boot.
# 5. Adds the xrdp user to the ssl-cert group (required for XRDP cert access).
# 6. Configures the current user's session to start XFCE when XRDP connects.
# 7. Prevents the VM from sleeping or hibernating:
#    - Masks sleep.target, suspend.target, hibernate.target, hybrid-sleep.target.
# 8. Restarts XRDP to apply all changes.
# ------------------------------------------------------------------------------

log() {
  echo -e "\n[\033[1;34mINFO\033[0m] $1"
}

trap 'echo -e "\n[\033[1;31mERROR\033[0m] Script failed at line $LINENO." >&2' ERR

if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] Please run this script with sudo."
  exit 1
fi

log "Updating package list..."
apt-get update -y

log "Installing XFCE4 desktop environment..."
DEBIAN_FRONTEND=noninteractive apt-get install -y xfce4

log "Installing xfce4-session..."
apt-get install -y xfce4-session

log "Installing XRDP..."
apt-get install -y xrdp

log "Enabling XRDP to start on boot..."
systemctl enable xrdp

log "Adding XRDP user to ssl-cert group..."
adduser xrdp ssl-cert

log "Setting XFCE4 as the default XRDP session..."
echo xfce4-session > "$HOME/.xsession"
chown "$(whoami)":"$(whoami)" "$HOME/.xsession"

log "Preventing the system from sleeping or hibernating..."
systemctl mask sleep.target
systemctl mask suspend.target
systemctl mask hibernate.target
systemctl mask hybrid-sleep.target

log "Restarting XRDP service..."
service xrdp restart

sleep 3
log "✅ XRDP + XFCE setup complete. Remote desktop is ready and sleep is disabled."
