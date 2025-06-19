import AppKit
import Foundation
import CoreAudio

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateMenuBar(text: "🔊 Listening...")

        // Start monitoring logs
        monitorLogs { rate in
            setOutputSampleRate(to: rate)
            DispatchQueue.main.async {
                self.updateMenuBar(text: String(format: "🎵 %.1f kHz", rate / 1000.0))
            }
        }
    }

    func updateMenuBar(text: String) {
        if let button = statusItem?.button {
            button.title = text
        }
    }
}
func setOutputSampleRate(to sampleRate: Double) {
    var deviceID = AudioDeviceID(0)
    var size = UInt32(MemoryLayout.size(ofValue: deviceID))
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultOutputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain)

    let status = AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &address, 0, nil, &size, &deviceID)

    guard status == noErr else {
        print("❌ Failed to get output device")
        return
    }

    var rate = sampleRate
    let rateSize = UInt32(MemoryLayout.size(ofValue: rate))
    var rateAddress = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyNominalSampleRate,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain)

    let setStatus = AudioObjectSetPropertyData(deviceID, &rateAddress, 0, nil, rateSize, &rate)

    if setStatus == noErr {
        print("✅ Changed sample rate to \(rate)")
    } else {
        print("❌ Failed to change sample rate (code: \(setStatus))")
    }
}
func monitorLogs(onSampleRateFound: @escaping (Double) -> Void) {
    let task = Process()
    let pipe = Pipe()

    task.executableURL = URL(fileURLWithPath: "/usr/bin/log")
    task.arguments = [
        "stream",
        "--style", "syslog",
        "--predicate",
        "eventMessage CONTAINS \"Created new AudioQueue for format:\""
    ]
    task.standardOutput = pipe

    let handle = pipe.fileHandleForReading
    handle.readabilityHandler = { fileHandle in
        if let line = String(data: fileHandle.availableData, encoding: .utf8),
           let rate = parseSampleRate(from: line) {
            print("🎵 Found sample rate: \(rate)")
            onSampleRateFound(rate)
        }
    }

    try? task.run()
}

func parseSampleRate(from log: String) -> Double? {
    let pattern = #"sampleRate:(\d+)"#
    if let regex = try? NSRegularExpression(pattern: pattern),
       let match = regex.firstMatch(in: log, range: NSRange(log.startIndex..., in: log)),
       let range = Range(match.range(at: 1), in: log) {
        return Double(log[range])
    }
    return nil
}

func setOutputFormat(sampleRate: Double, bitDepth: UInt32) {
    var deviceID = AudioDeviceID(0)
    var size = UInt32(MemoryLayout.size(ofValue: deviceID))
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultOutputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain)

    let status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &deviceID)
    guard status == noErr else {
        print("❌ Failed to get output device")
        return
    }

    // Set Sample Rate
    var rate = sampleRate
    var rateAddress = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyNominalSampleRate,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain)
    let rateSize = UInt32(MemoryLayout.size(ofValue: rate))
    let rateStatus = AudioObjectSetPropertyData(deviceID, &rateAddress, 0, nil, rateSize, &rate)

    if rateStatus == noErr {
        print("✅ Sample rate set to \(rate) Hz")
    } else {
        print("❌ Failed to set sample rate")
    }

    // Set Bit Depth (if supported)
    var streamCount: UInt32 = 0
    var streamCountSize = UInt32(MemoryLayout.size(ofValue: streamCount))
    var streamCountAddr = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyStreams,
        mScope: kAudioDevicePropertyScopeOutput,
        mElement: kAudioObjectPropertyElementMain)

    if AudioObjectGetPropertyDataSize(deviceID, &streamCountAddr, 0, nil, &streamCountSize) == noErr {
        streamCount = streamCountSize / UInt32(MemoryLayout<AudioStreamID>.size)

        var streams = [AudioStreamID](repeating: 0, count: Int(streamCount))
        AudioObjectGetPropertyData(deviceID, &streamCountAddr, 0, nil, &streamCountSize, &streams)

        for stream in streams {
            var format = AudioStreamBasicDescription()
            var formatSize = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
            var formatAddress = AudioObjectPropertyAddress(
                mSelector: kAudioStreamPropertyVirtualFormat,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain)

            if AudioObjectGetPropertyData(stream, &formatAddress, 0, nil, &formatSize, &format) == noErr {
                format.mSampleRate = sampleRate
                format.mBitsPerChannel = bitDepth
                format.mBytesPerFrame = bitDepth / 8 * format.mChannelsPerFrame
                format.mBytesPerPacket = format.mBytesPerFrame
                format.mFramesPerPacket = 1

                let setStatus = AudioObjectSetPropertyData(stream, &formatAddress, 0, nil, formatSize, &format)
                if setStatus == noErr {
                    print("✅ Bit depth set to \(bitDepth)")
                } else {
                    print("⚠️ Unable to set bit depth (device may not support changing it directly)")
                }
            }
        }
    }
}
