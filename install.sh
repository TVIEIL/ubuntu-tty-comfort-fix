#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "[-] Ce script d'installation doit être exécuté avec les privilèges root (sudo)."
  exit 1
fi

echo "[*] Installation des dépendances système de base..."
apt-get update -qq
apt-get install -y gpm nano kbd

# 1. Configuration de GPM
echo "[*] Configuration de GPM (/etc/gpm.conf)..."
cat << 'GPMCONF' > /etc/gpm.conf
device=/dev/input/mice
responsiveness=
repeat_type=raw
default_options=
boot_options=
type=imps2
append="-m /dev/input/mice"
GPMCONF

systemctl restart gpm || true

# 2. Activation de la souris dans nano
echo "[*] Activation du support de la souris dans nano..."
if ! grep -q "set mouse" /etc/nanorc 2>/dev/null; then
    echo "set mouse" >> /etc/nanorc
fi

# 3. Installation du démon tty-wheel-daemon
echo "[*] Déploiement du binaire tty-wheel-daemon..."
if [ -f "./tty-wheel-daemon" ]; then
    cp ./tty-wheel-daemon /usr/local/bin/tty-wheel-daemon
    chmod +x /usr/local/bin/tty-wheel-daemon
else
    echo "[-] Erreur : tty-wheel-daemon introuvable dans le dossier courant."
    exit 1
fi

# 4. Déploiement du service systemd
echo "[*] Configuration du service systemd..."
cp ./wheel-scroll.service /etc/systemd/system/wheel-scroll.service
systemctl daemon-reload
systemctl enable --now wheel-scroll.service

echo ""
echo "[+] ========================================================="
echo "[+] Installation terminée avec succès !"
echo "[+] - Défilement molette actif en tâche de fond (systemd)"
echo "[+] - Curseur souris actif dans nano"
echo "[+] - Copier/coller console actif via GPM"
echo "[+] ========================================================="
