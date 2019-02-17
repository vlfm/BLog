import BLog

public final class LogEntryFormatterMock {
    public typealias Handler = (LogEntry) -> String
    public var handler: Handler?
    
    public init() {}
}

extension LogEntryFormatterMock: LogEntryFormatter {
    public func format(_ entry: LogEntry) -> String {
        return handler?(entry) ?? ""
    }
}
