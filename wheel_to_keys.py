#!/usr/bin/env python3
import sys
import time
import evdev
from evdev import InputDevice, UInput, ecodes


def find_mouse_device():
    """Détecte dynamiquement la souris ou un périphérique disposant d'une molette."""
    try:
        devices = [InputDevice(path) for path in evdev.list_devices()]
    except Exception as e:
        print(f"Erreur lors de la lecture des périphériques d'entrée : {e}")
        return None

    # 1. Priorité aux périphériques avec 'mouse' ou 'optical' dans leur nom
    for dev in devices:
        name = dev.name.lower()
        if "mouse" in name or "optical" in name:
            return dev

    # 2. Détection de secours par les capacités (déplacement relatif + molette)
    for dev in devices:
        caps = dev.capabilities()
        if ecodes.EV_REL in caps and ecodes.REL_WHEEL in caps[ecodes.EV_REL]:
            return dev

    return None


def main():
    dev = find_mouse_device()
    if not dev:
        print("Erreur : aucune souris détectée.", file=sys.stderr)
        sys.exit(1)

    print(f"Périphérique sélectionné : {dev.name} ({dev.path})")

    # Clavier virtuel uinput pour réémettre les touches Flèche Haut / Bas (ou PageUp/Down)
    cap = {
        ecodes.EV_KEY: [ecodes.KEY_UP, ecodes.KEY_DOWN]
    }
    ui = UInput(cap, name="tty-wheel-keyboard-emulator")

    print("Démon à l'écoute des événements de la molette...")

    try:
        for event in dev.read_loop():
            # Détection de l'événement de défilement relatif (molette verticale)
            if event.type == ecodes.EV_REL and event.code == ecodes.REL_WHEEL:
                if event.value > 0:
                    # Molette vers le haut -> Touche Flèche Haut
                    ui.write(ecodes.EV_KEY, ecodes.KEY_UP, 1)
                    ui.write(ecodes.EV_KEY, ecodes.KEY_UP, 0)
                    ui.syn()
                elif event.value < 0:
                    # Molette vers le bas -> Touche Flèche Bas
                    ui.write(ecodes.EV_KEY, ecodes.KEY_DOWN, 1)
                    ui.write(ecodes.EV_KEY, ecodes.KEY_DOWN, 0)
                    ui.syn()

    except KeyboardInterrupt:
        pass
    except (OSError, PermissionError) as e:
        print(f"Périphérique déconnecté ou erreur d'accès : {e}", file=sys.stderr)
    finally:
        ui.close()


if __name__ == "__main__":
    main()
