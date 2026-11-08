#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "[-] Ce script doit être exécuté avec les privilèges root (sudo)."
  exit 1
fi

echo "[*] Arrêt et désactivation du service wheel-scroll..."
systemctl stop wheel-scroll.service 2>/dev/null || true
systemctl disable wheel-scroll.service 2>/dev/null || true

echo "[*] Suppression des fichiers installés..."
rm -f /etc/systemd/system/wheel-scroll.service
rm -f /usr/local/bin/tty-wheel-daemon

systemctl daemon-reload

echo "[*] Nettoyage de la configuration de nano..."
if [ -f /etc/nanorc ]; then
    sed -i '/set mouse/d' /etc/nanorc
fi

echo "[*] Arrêt du service GPM..."
systemctl stop gpm 2>/dev/null || true
systemctl disable gpm 2>/dev/null || true

echo ""
echo "[+] ========================================================="
echo "[+] Désinstallation terminée avec succès !"
echo "[+] Les services et binaires ont été complètement retirés."
echo "[+] ========================================================="
