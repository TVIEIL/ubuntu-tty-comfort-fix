#!/usr/bin/env python3
import os
import signal
import sys
import evdev
from evdev import InputDevice, UInput, ecodes

if os.geteuid() != 0:
  print("[-] Erreur : a lancer obligatoirement avec sudo !")
  sys.exit(1)

os.system("modprobe uinput")

device_path = None

if os.path.exists("/dev/input/event18"):
  try:
    dev = InputDevice("/dev/input/event18")
    if "mouse" in dev.name.lower() or "optical" in dev.name.lower():
      device_path = "/dev/input/event18"
  except Exception:
    pass

if not device_path:
  for path in evdev.list_devices():
    try:
      dev = InputDevice(path)
      if "mouse" in dev.name.lower() or "optical" in dev.name.lower():
        device_path = path
        break
    except Exception:
      continue

if not device_path:
  print("[-] Souris introuvable.")
  sys.exit(1)

mouse = InputDevice(device_path)
print(f"[+] Souris connectee : {mouse.name} sur {device_path}")

ui = UInput(
    {ecodes.EV_KEY: [ecodes.KEY_PAGEUP, ecodes.KEY_PAGEDOWN]},
    name="Virtual-Wheel-Keyboard",
)
print("[+] Pont actif ! Faites tourner la molette (Ctrl+C pour quitter)...")


def force_exit(signum, frame):
  signal.signal(signal.SIGINT, signal.SIG_IGN)
  signal.signal(signal.SIGTERM, signal.SIG_IGN)
  try:
    ui.close()
    mouse.close()
  except Exception:
    pass
  print("\n[+] Arret propre.")
  os._exit(0)


signal.signal(signal.SIGINT, force_exit)
signal.signal(signal.SIGTERM, force_exit)

for event in mouse.read_loop():
  if event.type == ecodes.EV_REL and event.code == ecodes.REL_WHEEL:
    key = ecodes.KEY_PAGEUP if event.value > 0 else ecodes.KEY_PAGEDOWN
    ui.write(ecodes.EV_KEY, key, 1)
    ui.write(ecodes.EV_KEY, key, 0)
    ui.syn()
