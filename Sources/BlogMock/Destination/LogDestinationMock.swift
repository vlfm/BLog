import BLog

public final class LogDestinationMock {
    public typealias Handler = (LogEntry) throws -> Void
    public var handler: Handler?
    
    public init() {}
}

extension LogDestinationMock: LogDestination {
    public func receive(_ entry: LogEntry) throws {
        try handler?(entry)
    }
}
