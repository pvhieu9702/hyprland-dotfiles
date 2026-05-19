# Waybar

## Structure

```
waybar/
├── config.jsonc                     # Entry point, loads all modules
├── style.css                        # Main stylesheet
├── modules/                         # Each module in its own file
│   ├── audio.jsonc
│   ├── battery.jsonc
│   ├── clock.jsonc
│   ├── connections.jsonc            # Network & Bluetooth
│   ├── distro.jsonc                 # ← Applications embedded
│   ├── groups.jsonc                 # Drawer grouping
│   ├── idle-inhibitor.jsonc
│   ├── power-profiles-daemon.jsonc
│   ├── storage.jsonc
│   ├── system.jsonc                 # CPU, RAM, temperature
│   ├── tray-notif.jsonc             # Tray + SwayNC
│   └── workspace.jsonc
└── tokens/                          # CSS variables
    ├── colors.css                   # ← edit colors here
    ├── batt-clock.css
    ├── slider.css
    ├── state.css
    ├── widget.css
    └── workspace.css
```

---

## Modules

| Module | Interaction | Action |
| --- | --- | --- |
| Network | Left click | Show `nm-applet` in tray|
| | Right click | Hide `nm-applet` in tray|
| | Scroll up | Enable Wi-Fi |
| | Scroll down | Disable Wi-Fi |
| Bluetooth | Left click | Open `blueman-manager` |
| | Right click | Toggle power on/off |
| SwayNC | Left click | Open/close panel |
| | Right click | Toggle Do Not Disturb |
| Power Profiles | Click | Toggle Saver > Balance > Performance |
| Idle Inhibitor | Click | Toggle screen dimming |

---

## Colors

Edit `tokens/colors.css` to match your preference.

> [!TIP]
> For automatic color generation from your wallpaper, see `.config/matugen` and `.config/zsh`.

---

## Dependencies

| Package | Purpose |
| --- | --- |
| [Waybar](https://github.com/Alexays/Waybar) | Status bar |
| [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) | Notification center |
| [nm-applet](https://wiki.archlinux.org/title/NetworkManager) | Network manager |
| [blueman](https://wiki.archlinux.org/title/Blueman) | Bluetooth manager |
| [pipewire](https://wiki.archlinux.org/title/PipeWire) / [pulseaudio](https://wiki.archlinux.org/title/PulseAudio) | Audio |

---

## Acknowledgments
* **[Waybar](https://github.com/Alexays/Waybar)** - Created by **Alexays**. Huge thanks for this amazing and highly customizable status bar.
* All the contributors who have made Waybar what it is today.
---
