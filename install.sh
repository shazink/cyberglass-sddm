#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_NAME="cyberglass-sddm"
TARGET_DIR="/usr/share/sddm/themes/${THEME_NAME}"

echo "========================================="
echo " Installing CyberGlass SDDM Theme"
echo " Target: ${TARGET_DIR}"
echo "========================================="

sudo mkdir -p "${TARGET_DIR}"
sudo cp -r "${SCRIPT_DIR}"/* "${TARGET_DIR}/"
sudo chmod -R a+rX "${TARGET_DIR}"

echo ""
echo "Installation complete!"
echo "You can now select 'CyberGlass' in KDE System Settings -> Login Screen (SDDM)"
echo "Or activate it manually via: sudo sddm --example-config or /etc/sddm.conf"

