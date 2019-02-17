@testable import BLog
@testable import BLogMock
import XCTest

extension FormattedLogOutputMock {
    func setUpCollector(testCase: XCTestCase) -> Collector<String> {
        let collector = Collector<String>(testCase: testCase)
        handler = { entry in
            collector.add(entry)
        }
        return collector
    }
}
