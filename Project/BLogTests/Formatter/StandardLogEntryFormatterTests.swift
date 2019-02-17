@testable import BLog
@testable import BLogMock
import XCTest

class StandardLogEntryFormatterTests: XCTestCase {
    func testFormat() {
        for (index, package) in makeTestData().enumerated() {
            let formatter = StandardLogEntryFormatter(package.configuration)
            let output = formatter.format(package.entry)
            XCTAssertEqual(output, package.output, "Failed \(index) case")
        }
    }
}

extension StandardLogEntryFormatterTests {
    struct TestPackage {
        let configuration: StandardLogEntryFormatter.Configuration
        let entry: LogEntry
        let output: String
    }
}

extension StandardLogEntryFormatterTests {
    private func makeTestData() -> [TestPackage] {
        let date = makeDate()
        
        var consoleWithSource = StandardLogEntryFormatter.Configuration.console
        var fileWithSource = StandardLogEntryFormatter.Configuration.file
        
        consoleWithSource.shouldIncludeSource = true
        fileWithSource.shouldIncludeSource = true
        
        return [
            TestPackage(
                configuration: .console,
                entry: makeLogEntry(date, .debug),
                output: "23:59:59.999 | ◼️ | Hello, world"
            ),
            TestPackage(
                configuration: .console,
                entry: makeLogEntry(date, .error),
                output: "23:59:59.999 | ❌ | Hello, world"
            ),
            TestPackage(
                configuration: .console,
                entry: makeLogEntry(date, .fatal),
                output: "23:59:59.999 | 💀 | Hello, world"
            ),
            TestPackage(
                configuration: .console,
                entry: makeLogEntry(date, .info),
                output: "23:59:59.999 | 🔷 | Hello, world"
            ),
            TestPackage(
                configuration: .console,
                entry: makeLogEntry(date, .raw),
                output: "Hello, world"
            ),
            TestPackage(
                configuration: .console,
                entry: makeLogEntry(date, .verbose),
                output: "23:59:59.999 | ◻️ | Hello, world"
            ),
            TestPackage(
                configuration: .console,
                entry: makeLogEntry(date, .warning),
                output: "23:59:59.999 | ⚠️ | Hello, world"
            ),
            TestPackage(
                configuration: .file,
                entry: makeLogEntry(date, .debug),
                output: "31/12/1999 23:59:59.999 | Debug | Hello, world"
            ),
            TestPackage(
                configuration: .file,
                entry: makeLogEntry(date, .error),
                output: "31/12/1999 23:59:59.999 | Error | Hello, world"
            ),
            TestPackage(
                configuration: .file,
                entry: makeLogEntry(date, .fatal),
                output: "31/12/1999 23:59:59.999 | Fatal | Hello, world"
            ),
            TestPackage(
                configuration: .file,
                entry: makeLogEntry(date, .info),
                output: "31/12/1999 23:59:59.999 | Info | Hello, world"
            ),
            TestPackage(
                configuration: .file,
                entry: makeLogEntry(date, .raw),
                output: "Hello, world"
            ),
            TestPackage(
                configuration: .file,
                entry: makeLogEntry(date, .verbose),
                output: "31/12/1999 23:59:59.999 | Verbose | Hello, world"
            ),
            TestPackage(
                configuration: .file,
                entry: makeLogEntry(date, .warning),
                output: "31/12/1999 23:59:59.999 | Warning | Hello, world"
            ),
            TestPackage(
                configuration: consoleWithSource,
                entry: makeLogEntry(date, .debug),
                output: "23:59:59.999 | ◼️ | File.function:42 | Hello, world"
            ),
            TestPackage(
                configuration: fileWithSource,
                entry: makeLogEntry(date, .debug),
                output: "31/12/1999 23:59:59.999 | Debug | File.function:42 | Hello, world"
            )
        ]
    }
    
    private func makeDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss.SSS"
        return formatter.date(from: "31/12/1999 23:59:59.999")!
    }
    
    private func makeLogEntry(_ date: Date,
                              _ messageType: LogEntry.Message.Kind) -> LogEntry {
        return LogEntry(
            date: date,
            message: LogEntry.Message(
                text: "Hello, world",
                kind: messageType),
            source: LogEntry.Source(file: "File", function: "function", line: 42)
        )
    }
}
