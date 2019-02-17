@testable import BLog
@testable import BLogMock
import XCTest

extension LoggerMock {
    func setUpCollector(testCase: XCTestCase) -> Collector<(LogEntry.Message, LogEntry.Source?, Bool)> {
        let collector = Collector<(LogEntry.Message, LogEntry.Source?, Bool)>(testCase: testCase)
        handler = { message, source, sync in
            let entry = (message, source, sync)
            collector.add(entry)
        }
        return collector
    }
}
