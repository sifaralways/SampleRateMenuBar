import Foundation
import CoreAudio

class AudioManager {
    static func setOutputSampleRate(to sampleRate: Double) {
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
}
