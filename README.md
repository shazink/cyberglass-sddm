# CyberGlass SDDM Theme for KDE Plasma 6

A modern, glassmorphic login screen theme for SDDM on KDE Plasma 6 (Qt 6 & Wayland).

## Features
- **Dynamic Aurora Lighting**: 3 floating neon gradient orbs (Cyan, Violet, Magenta) with fluid sine-wave motion behind a dark cinematic wallpaper.
- **Glassmorphism Card**: Frosted glass panel with rounded corners, drop shadows, and subtle glowing cyan accents.
- **Time-Aware Greeting & Clock**: Real-time digital clock, date, and greeting (*"Good morning / afternoon / evening"*).
- **Interactive Avatar**: Circular user badge with breathing neon halo ring.
- **Password Field & Micro-interactions**:
  - Show / hide password eye toggle button.
  - **Caps Lock detection**: automatically alerts you if Caps Lock is ON.
  - **Shake feedback on error**: smoothly shakes the card horizontally if authentication fails.
- **Floating Dock**:
  - Session switcher pill (*Plasma Wayland / X11*).
  - Power controls with hover tooltips (*Sleep, Restart, Shut Down*).

## Background Video (Required)

The background video is not included in this repository because of GitHub's file size limit.

To enable the animated background:

1. Obtain the background video.
2. Place it inside the `assets/` directory.
3. Rename the file to **`background.mp4`**.

The expected file path is:

```text
cyberglass-sddm/
└── assets/
    └── background.mp4
```

Make sure the filename and folder match exactly. The theme expects the video at `assets/background.mp4`.

Without this file, the animated video background will not be displayed.

## Quick Test

Preview the theme in a test window right now (without rebooting):

```bash
./test.sh
# or
sddm-greeter-qt6 --test-mode --theme .
```

## Installation

Install system-wide to `/usr/share/sddm/themes/`:

```bash
./install.sh
```

Then open **KDE System Settings** → **Colors & Themes** (or **Appearance**) → **Login Screen (SDDM)** and select **CyberGlass**.
