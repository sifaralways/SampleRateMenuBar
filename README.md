# Apple Music Sample Rate Sync

A macOS menu bar app that syncs your Audio MIDI output sample rate to the current Apple Music track.

🎧 Automatically switches your output to 44.1, 48, 96, or 192 kHz — based on Apple Music logs.

## Features

- Lightweight Swift app with no UI
- Displays current sample rate in macOS menu bar
- Monitors Apple Music logs (not system-wide)
- Prevents feedback loops with safety checks

## Requirements

- macOS 12+
- Full Disk Access (to read system logs)

## Setup

1. Clone the repo
2. Open `SampleRateMenuBar.xcodeproj` in Xcode
3. Build and run
4. Grant Full Disk Access in System Settings

## License

MIT or [your preferred license]
