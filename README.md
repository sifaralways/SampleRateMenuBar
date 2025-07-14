# Deprecated and Replaced by MAC4MAC. https://github.com/sifaralways/Mac4Mac. Please use new file, this will not be maintaned any more.



# 🎵 SampleRateMenuBar — Match macOS Sample Rate to Apple Music Playback

**SampleRateMenuBar** is a lightweight macOS menu bar app that automatically changes your system’s output sample rate to match the actual sample rate of songs playing in Apple Music.

This avoids resampling, ensures bit-perfect playback, and enhances the listening experience for audiophiles using external DACs or high-resolution audio setups.

---

## ✨ Features

- ✅ **Detects real song playback**, not just queued tracks
- 🔄 **Synchronizes system output sample rate** (e.g. 44.1kHz, 48kHz, 96kHz, 192kHz) with Apple Music
- 🎧 Displays current output device, sample rate, and bit depth in the menu bar
- 🛑 Works around Apple Music’s lack of automatic switching
- ⚙️ Lightweight, sandbox-free, and requires no admin privileges
- 🍎 Built natively using Swift + AppKit

---

## 📸 Screenshot

![image](https://github.com/user-attachments/assets/d1d7e0d2-2e44-4547-8320-9783c2430481)


---

## 📦 Installation

### Option 1: Prebuilt App (Recommended)

1. [Download the latest release](https://github.com/sifaralways/SampleRateMenuBar/releases)
2. Move it to `/Applications`
3. On first run, grant the following permissions:
   - ✅ **Automation** → allow control of Music
   - ✅ **Accessibility**
   - ✅ **Full Disk Access** (to read Apple system logs)

### Option 2: Build from Source

```bash
git clone https://github.com/sifaralways/SampleRateMenuBar.git
cd SampleRateMenuBar
open SampleRateMenuBar.xcodeproj

```
## 🖥 Requirements
	•	macOS Sequoia (15.4) or later
	•	Music app (Apple Music)
	•	Full Disk Access + Automation permission

⸻

## 🙏 Credits

This app is inspired by the original idea from https://github.com/vincentneo/LosslessSwitcher


## 👋 Contribute

PRs welcome! If you find bugs or have ideas, feel free to open an issue.
