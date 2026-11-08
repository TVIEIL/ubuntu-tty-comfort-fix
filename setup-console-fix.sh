#!/usr/bin/env bash
set -e

# Vérification des droits root
if [ "$EUID" -ne 0 ]; then
  echo "[-] Ce script doit être exécuté avec les privilèges root (sudo)."
  exit 1
fi

echo "[*] 1/4 - Installation et configuration de GPM (souris TTY)..."
export DEBIAN_FRONTEND=noninteractive
apt update -y
apt install -y gpm

# Configuration /etc/gpm.conf
cat << 'GPM_CONF' > /etc/gpm.conf
device=/dev/input/mice
responsiveness=
type=exps2
append=""
sample_rate=
GPM_CONF

systemctl restart gpm
systemctl enable gpm

echo "[*] 2/4 - Activation de la souris dans nano..."
# Configuration globale de nano
if [ -f /etc/nanorc ]; then
  sed -i '/^[# ]*set mouse/d' /etc/nanorc
  echo "set mouse" >> /etc/nanorc
fi

# Configuration pour l'utilisateur qui a lancé sudo
if [ -n "$SUDO_USER" ]; then
  USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
  if [ -d "$USER_HOME" ]; then
    touch "$USER_HOME/.nanorc"
    sed -i '/^[# ]*set mouse/d' "$USER_HOME/.nanorc"
    echo "set mouse" >> "$USER_HOME/.nanorc"
    chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/.nanorc"
  fi
fi

echo "[*] 3/4 - Correction du mappage Caps_Lock..."
# Création d'une table kmap dédiée pour fixer le keycode 58
mkdir -p /etc/console-setup
cat << 'KMAP' > /etc/console-setup/caps-fix.kmap
keycode 58 = Caps_Lock
KMAP

# Application immédiate sur la console active si disponible
if command -v loadkeys >/dev/null 2>&1; then
  loadkeys /etc/console-setup/caps-fix.kmap 2>/dev/null || true
fi

echo "[*] 4/4 - Mise en place du service systemd pour la LED et le keymap..."
cat << 'SERVICE' > /etc/systemd/system/console-caps-led-fix.service
[Unit]
Description=Fix Caps Lock keycode and LED behavior on TTY
After=systemd-vconsole-setup.service console-setup.service
DefaultDependencies=no

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c '\
  loadkeys /etc/console-setup/caps-fix.kmap 2>/dev/null || true; \
  for tty in /dev/tty[1-6]; do \
    if [ -e "$tty" ]; then \
      setleds -D +caps < "$tty" 2>/dev/null || true; \
    fi; \
  done'

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable --now console-caps-led-fix.service

# Application immédiate sur le TTY actuel si applicable
for tty in /dev/tty[1-6]; do
  if [ -e "$tty" ]; then
    setleds -D +caps < "$tty" 2>/dev/null || true
  fi
done

echo "[+] Configuration terminée avec succès !"
echo "[+] La souris est active en TTY et dans nano."
echo "[+] La LED Caps Lock est désormais synchronisée."
