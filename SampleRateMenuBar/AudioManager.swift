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
    static func getOutputDeviceName() -> String? {
        var deviceID = AudioDeviceID(0)
        var size = UInt32(MemoryLayout.size(ofValue: deviceID))
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain)

        guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &deviceID) == noErr else {
            return nil
        }

        var name: CFString?
        var nameSize = UInt32(MemoryLayout<CFString?>.size)
        var nameAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain)

        let status = withUnsafeMutablePointer(to: &name) { ptr -> OSStatus in
            AudioObjectGetPropertyData(deviceID, &nameAddress, 0, nil, &nameSize, ptr)
        }

        return (status == noErr && name != nil) ? (name! as String) : nil
    }
    static func getBitDepth() -> UInt32? {
        var deviceID = AudioDeviceID(0)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain)

        guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &deviceID) == noErr else {
            return nil
        }

        var streamCountSize: UInt32 = 0
        var streamCountAddr = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain)

        if AudioObjectGetPropertyDataSize(deviceID, &streamCountAddr, 0, nil, &streamCountSize) != noErr {
            return nil
        }

        let streamCount = streamCountSize / UInt32(MemoryLayout<AudioStreamID>.size)
        var streams = [AudioStreamID](repeating: 0, count: Int(streamCount))
        AudioObjectGetPropertyData(deviceID, &streamCountAddr, 0, nil, &streamCountSize, &streams)

        for stream in streams {
            var desc = AudioStreamBasicDescription()
            var descSize = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
            var formatAddress = AudioObjectPropertyAddress(
                mSelector: kAudioStreamPropertyVirtualFormat,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain)

            if AudioObjectGetPropertyData(stream, &formatAddress, 0, nil, &descSize, &desc) == noErr {
                return desc.mBitsPerChannel
            }
        }

        return nil
    }
}
