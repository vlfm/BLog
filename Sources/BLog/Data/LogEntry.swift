import Foundation

public struct LogEntry: Equatable {
    public let date: Date
    public let message: Message
    public let source: Source?
    
    public init(date: Date, message: Message, source: Source?) {
        self.date = date
        self.message = message
        self.source = source
    }
}
