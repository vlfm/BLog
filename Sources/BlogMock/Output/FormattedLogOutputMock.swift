import BLog

public final class FormattedLogOutputMock {
    public typealias Handler = (String) throws -> Void
    public var handler: Handler?
    
    public init() {}
}

extension FormattedLogOutputMock: FormattedLogOutput {
    public func receive(_ formattedLogEntry: String) throws {
        try handler?(formattedLogEntry)
    }
}
