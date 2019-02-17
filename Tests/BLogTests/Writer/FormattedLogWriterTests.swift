@testable import BLog
@testable import BLogMock
import XCTest

class FormattedLogWriterTests: XCTestCase {
    private var formatter: LogEntryFormatterMock!
    private var output: FormattedLogOutputMock!
    private var writer: FormattedLogWriter!
    private var entry: LogEntry!
    
    override func setUp() {
        formatter = LogEntryFormatterMock()
        output = FormattedLogOutputMock()
        writer = FormattedLogWriter(formatter, output)
        
        let message = LogEntry.Message(text: "123", kind: .debug)
        let source = LogEntry.Source(file: "abc", function: "func", line: 42)
        entry = LogEntry(date: Date(), message: message, source: source)
    }
    
    func testFormatterReceivesEntry() throws {
        var receivedEntry: LogEntry?
        formatter.handler = { entry in
            receivedEntry = entry
            return ""
        }
        try writer.receive(entry)
        XCTAssertEqual(receivedEntry, entry)
    }
    
    func testOutputReceivesEntry() throws {
        formatter.handler = { _ in return "999"}
        let collector = output.setUpCollector(testCase: self)
        try writer.receive(entry)
        collector.wait()
        XCTAssertEqual(collector.elements, ["999"])
    }
    
    func testOutputThrowsError() {
        formatter.handler = { _ in return "999"}
        
        let expectedError = TextError("Some Error")
        output.handler = { _ in throw expectedError }
        
        do {
            try writer.receive(entry)
        } catch {
            XCTAssertEqual(error as? TextError, expectedError)
        }
    }
}
