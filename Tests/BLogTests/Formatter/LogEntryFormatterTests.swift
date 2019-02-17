@testable import BLog
@testable import BLogMock
import XCTest

class LogEntryFormatterTests: XCTestCase {
    var date: Date!
    var formatter: LogEntryFormatter!
    
    override func setUp() {
        super.setUp()
        date = makeDate()
    }
    
    func performTestFormatSource() {
        let message = LogEntry.Message(text: "", kind: .verbose)
        let source = LogEntry.Source(file: "123/456/abc.swift", function: "func", line: 42)
        let entry = LogEntry(date: Date(), message: message, source: source)
        XCTAssertEqual(formatter.formatSource(entry), "abc.swift.func:42")
    }

    func performTestFormatSourceNil() {
        let message = LogEntry.Message(text: "", kind: .verbose)
        let entry = LogEntry(date: Date(), message: message, source: nil)
        XCTAssertNil(formatter.formatSource(entry))
    }
    
    func makeLogEntry(_ messageType: LogEntry.Message.Kind, _ source: LogEntry.Source? = nil) -> LogEntry {
        return LogEntry(
            date: date,
            message: LogEntry.Message(
                text: "Hello, world",
                kind: messageType),
            source: source
        )
    }
    
    func makeDate() -> Date {
        return Date()
    }
}
