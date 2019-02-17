@testable import BLog
@testable import BLogMock
import XCTest

extension LogDestinationMock {
    func addDelay(_ delay: TimeInterval) {
        let previousHandler = handler
        handler = { entry in
            Thread.sleep(forTimeInterval: delay)
            try previousHandler?(entry)
        }
    }
    
    func setUpCollector(testCase: XCTestCase) -> Collector<LogEntry> {
        let collector = Collector<LogEntry>(testCase: testCase)
        handler = { entry in
            collector.add(entry)
        }
        return collector
    }
}
