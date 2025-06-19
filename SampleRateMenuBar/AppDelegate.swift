import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var currentSampleRate: Double = 44100
    var isMonitoringPaused: Bool = false
    var logMonitorTask: Process?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.title = String(format: "🎵 %.1f kHz", currentSampleRate / 1000.0)
        }

        updateMenu()

        LogMonitor.startMonitoring(taskRef: &logMonitorTask) { [weak self] rate in
            guard let self = self, !self.isMonitoringPaused else { return }

            AudioManager.setOutputSampleRate(to: rate)
            self.currentSampleRate = rate

            DispatchQueue.main.async {
                self.updateMenu()
                self.statusItem?.button?.title = String(format: "🎵 %.1f kHz", rate / 1000.0)
            }
        }
    }

    func updateMenu() {
        let menu = NSMenu()

        // Output Device
        let deviceName = AudioManager.getOutputDeviceName() ?? "Unknown"
        menu.addItem(withTitle: "🎧 Device: \(deviceName)", action: nil, keyEquivalent: "")

        // Sample Rate
        menu.addItem(withTitle: String(format: "📈 Sample Rate: %.1f kHz", currentSampleRate / 1000.0), action: nil, keyEquivalent: "")

        // Bit Depth
        if let bitDepth = AudioManager.getBitDepth() {
            menu.addItem(withTitle: "🧪 Bit Depth: \(bitDepth)-bit", action: nil, keyEquivalent: "")
        }

        // Pause/Resume Monitoring
        let toggleTitle = isMonitoringPaused ? "▶️ Resume Monitoring" : "⏸️ Pause Monitoring"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(toggleMonitoring), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        // Open Audio MIDI Setup
        let openAudioMIDI = NSMenuItem(title: "🎛️ Open Audio MIDI Setup", action: #selector(openAudioMIDISetup), keyEquivalent: "")
        openAudioMIDI.target = self
        menu.addItem(openAudioMIDI)

        // Quit
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(quitApp), keyEquivalent: "q")

        statusItem?.menu = menu
    }

    @objc func toggleMonitoring() {
        isMonitoringPaused.toggle()
        updateMenu()

        if isMonitoringPaused {
            logMonitorTask?.terminate()
            logMonitorTask = nil
            print("🛑 Monitoring paused")
        } else {
            LogMonitor.startMonitoring(taskRef: &logMonitorTask) { [weak self] rate in
                guard let self = self, !self.isMonitoringPaused else { return }

                AudioManager.setOutputSampleRate(to: rate)
                self.currentSampleRate = rate

                DispatchQueue.main.async {
                    self.updateMenu()
                    self.statusItem?.button?.title = String(format: "🎵 %.1f kHz", rate / 1000.0)
                }
            }
            print("▶️ Monitoring resumed")
        }
    }

    @objc func openAudioMIDISetup() {
        let path = "/System/Applications/Utilities/Audio MIDI Setup.app"
        let url = URL(fileURLWithPath: path)

        let config = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.openApplication(at: url, configuration: config) { app, error in
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
