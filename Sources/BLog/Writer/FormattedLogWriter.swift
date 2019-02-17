import Foundation

public final class FormattedLogWriter {
    private let formatter: LogEntryFormatter
    private let output: FormattedLogOutput
    
    public init(_ formatter: LogEntryFormatter, _ output: FormattedLogOutput) {
        self.formatter = formatter
        self.output = output
    }
}

extension FormattedLogWriter: LogDestination {
    public func receive(_ entry: LogEntry) throws {
        let message = formatter.format(entry)
        try output.receive(message)
    }
}
