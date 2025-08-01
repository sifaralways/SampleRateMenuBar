import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var currentSampleRate: Double = 44100
    var isMonitoringPaused: Bool = false
    var trackChangeMonitor = TrackChangeMonitor()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu bar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.title = String(format: "🎵 %.1f kHz", currentSampleRate / 1000.0)
        }
        updateMenu()

        // Start watching for track changes
        trackChangeMonitor.onTrackChange = { [weak self] in
            LogMonitor.fetchLatestSampleRate { rate in
                guard let self = self else { return }
                AudioManager.setOutputSampleRate(to: rate)
                self.currentSampleRate = rate
                DispatchQueue.main.async {
                    self.updateMenu()
                    self.statusItem?.button?.title = String(format: "🎵 %.1f kHz", rate / 1000.0)
                }
            }
        }
        trackChangeMonitor.startMonitoring()
    }

    func updateMenu() {
        let menu = NSMenu()

        // Device name
        let deviceName = AudioManager.getOutputDeviceName() ?? "Unknown"
        menu.addItem(withTitle: "🎧 Device: \(deviceName)", action: nil, keyEquivalent: "")

        // Sample rate
        menu.addItem(withTitle: String(format: "📈 Sample Rate: %.1f kHz", currentSampleRate / 1000.0), action: nil, keyEquivalent: "")

        // Bit depth (optional)
        if let bitDepth = AudioManager.getBitDepth() {
            menu.addItem(withTitle: "🧪 Bit Depth: \(bitDepth)-bit", action: nil, keyEquivalent: "")
        }

        // Open Audio MIDI Setup
        let midiItem = NSMenuItem(title: "🎛️ Open Audio MIDI Setup", action: #selector(openAudioMIDISetup), keyEquivalent: "")
        midiItem.target = self
        menu.addItem(midiItem)

        // Quit
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(quitApp), keyEquivalent: "q")

        statusItem?.menu = menu
    }

    @objc func openAudioMIDISetup() {
        let path = "/System/Applications/Utilities/Audio MIDI Setup.app"
        let url = URL(fileURLWithPath: path)
        let config = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.openApplication(at: url, configuration: config) { _, error in
            if let error = error {
                print("❌ Failed to open Audio MIDI Setup: \(error)")
            } else {
                print("🎛️ Audio MIDI Setup launched")
            }
        }
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }
}
