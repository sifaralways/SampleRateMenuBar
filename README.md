# Apple Music Sample Rate Sync for MAC OS 26.0

# Tested on 
# 1.  26.0 Beta (25A5279m)



A macOS menu bar app that syncs your Audio MIDI output sample rate to the current Apple Music track.

🎧 Automatically switches your output to 44.1, 48, 96, or 192 kHz — based on Apple Music logs.

## Features

- Lightweight Swift app with Minimal UI
- Displays current sample rate in macOS menu bar
- Open Audio Midi settings right from menu bar
- Monitors Apple Music track changes and matches sample rate of external DAC to currently playing song
- Prevents feedback loops with safety checks

## Requirements

- macOS 26+
- Full Disk Access (to read system logs)

## Setup

1. Clone the repo
2. Open `SampleRateMenuBar.xcodeproj` in Xcode
3. Build and run
4. Grant Full Disk Access in System Settings


## License

Open Source
