# Ubuntu TTY Comfort Fix

Un ensemble d'outils et de services pour restaurer une ergonomie moderne sur les consoles virtuelles textuelles Linux (`/dev/tty1` à `/dev/tty6`), sans installer de serveur graphique (X11 ou Wayland).

## Fonctionnalités

* **Molette de souris fonctionnelle en console TTY :** Démon autonome en arrière-plan (`tty-wheel-daemon`) interceptant les événements matériels `REL_WHEEL` via `evdev` pour injecter des frappes clavier `PageUp` / `PageDown` via `/dev/uinput`.
  * Défilement fluide dans `man`, `less`, `journalctl`, `git log`.
  * Navigation page par page dans `nano`.
  * Parcours rapide de l'historique des commandes dans `bash`.
* **Support souris en console (GPM) :** Clic, sélection et copier/coller en mode texte pur.
* **Curseur souris natif dans `nano` :** Clic direct pour positionner le curseur.
* **Service d'arrière-plan résilient :** Supervisé automatiquement par `systemd` avec redémarrage en cas d'incident ou de déconnexion.

## Installation rapide

Clonez le dépôt puis exécutez le script d'installation en mode administrateur :

```bash
git clone [https://github.com/TVIEIL/ubuntu-tty-comfort-fix.git](https://github.com/TVIEIL/ubuntu-tty-comfort-fix.git)
cd ubuntu-tty-comfort-fix
sudo ./install.sh
```
## Installation via PPA (Ubuntu)

```bash
sudo add-apt-repository ppa:tvieil/ppa
sudo apt update
sudo apt install ubuntu-tty-comfort-fix
```

## Désinstallation

Pour supprimer l'ensemble des services, configurations et binaires du système :

```bash
cd ubuntu-tty-comfort-fix
sudo ./uninstall.sh
```


