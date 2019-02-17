import Foundation

public protocol LogEntryFormatter {
    func format(_ entry: LogEntry) -> String
}

extension LogEntryFormatter {
    func formatSource(_ entry: LogEntry) -> String? {
        if let source = entry.source {
            let file = URL(fileURLWithPath: source.file).lastPathComponent
            return "\(file).\(source.function):\(source.line)"
        }
        return nil
    }
}
