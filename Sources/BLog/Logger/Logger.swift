import Foundation

public protocol Logger {
    func log(_ message: LogEntry.Message, _ source: LogEntry.Source?, sync: Bool)
}

extension Logger {
    public func log(_ message: LogEntry.Message, _ source: LogEntry.Source?) {
        log(message, source, sync: false)
    }
}

extension Logger {
    public func log(_ messageKind: LogEntry.Message.Kind,
                    _ messageText: String,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line,
                    sync: Bool = false) {
        let message = LogEntry.Message(text: messageText, kind: messageKind)
        let source = LogEntry.Source(file: file, function: function, line: line)
        log(message, source, sync: sync)
    }
}
