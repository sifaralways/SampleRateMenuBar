import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateMenuBar(text: "🔊 Listening...")

        LogMonitor.startMonitoring { [weak self] rate in
            AudioManager.setOutputSampleRate(to: rate)
            DispatchQueue.main.async {
                self?.updateMenuBar(text: String(format: "🎵 %.1f kHz", rate / 1000.0))
            }
        }
    }

    func updateMenuBar(text: String) {
        statusItem?.button?.title = text
    }
}
