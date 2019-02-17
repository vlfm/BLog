import Foundation

public final class ConsoleLogOutput {
    public init() {}
}

extension ConsoleLogOutput: FormattedLogOutput {
    public func receive(_ formattedLogEntry: String) throws {
        print(formattedLogEntry)
    }
}
