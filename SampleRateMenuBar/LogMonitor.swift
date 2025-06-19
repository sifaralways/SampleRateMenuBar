import Foundation

class LogMonitor {
    static func fetchLatestSampleRate(completion: @escaping (Double) -> Void) {
        let task = Process()
        let pipe = Pipe()

        task.executableURL = URL(fileURLWithPath: "/usr/bin/log")
        task.arguments = [
            "show",
            "--style", "syslog",
            "--predicate", "eventMessage CONTAINS \"Created new AudioQueue for format:\"",
            "--last", "10s"
        ]
        task.standardOutput = pipe

        _ = pipe.fileHandleForReading
        task.terminationHandler = { _ in
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let log = String(data: data, encoding: .utf8),
               let rate = parseSampleRate(from: log) {
                DispatchQueue.main.async {
                    print("🎵 Detected sample rate in history: \(rate)")
                    completion(rate)
                }
            }
        }

        do {
            try task.run()
        } catch {
            print("❌ Failed to run log show: \(error)")
        }
    }

    private static func parseSampleRate(from log: String) -> Double? {
        let pattern = #"sampleRate:(\d+)"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: log, range: NSRange(log.startIndex..., in: log)) ?? []

        guard let match = matches.last,
              let range = Range(match.range(at: 1), in: log) else {
            return nil
        }

        return Double(log[range])
    }
}
