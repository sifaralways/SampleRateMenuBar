//
//  LogMonitor.swift
//  SampleRateMenuBar
//
//  Created by Akshat Singhal on 19/6/2025.
//


import Foundation

class LogMonitor {
    static func startMonitoring(onSampleRateFound: @escaping (Double) -> Void) {
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

        do {
            try task.run()
        } catch {
            print("❌ Failed to start log monitor: \(error)")
        }
    }

    private static func parseSampleRate(from log: String) -> Double? {
        let pattern = #"sampleRate:(\d+)"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: log, range: NSRange(log.startIndex..., in: log)),
           let range = Range(match.range(at: 1), in: log) {
            return Double(log[range])
        }
        return nil
    }
}