import BLog

public final class LoggerMock {
    public typealias Handler = (LogEntry.Message, LogEntry.Source?, Bool) -> Void
    public var handler: Handler?
    
    public init() {}
}

extension LoggerMock: Logger {
    public func log(_ message: LogEntry.Message, _ source: LogEntry.Source?, sync: Bool) {
        handler?(message, source, sync)
    }
}
