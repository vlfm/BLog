import Foundation

extension LogEntry.Message {
    public enum Kind: CaseIterable, Equatable {
        case debug
        case error
        case fatal
        case info
        case raw
        case verbose
        case warning
    }
}
