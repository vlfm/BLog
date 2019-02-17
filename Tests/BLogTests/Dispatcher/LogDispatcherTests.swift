@testable import BLog
@testable import BLogMock
import XCTest

class LogDispatcherTests: XCTestCase {
    private var dispatcher: LogDispatcher!
    private var fixedClockDispatcher: LogDispatcher!
    
    private var destination: LogDestinationMock!
    private var collector: Collector<LogEntry>!
    private var date: Date!
    
    override func setUp() {
        super.setUp()
        
        let date = Date()
        let queue = DispatchQueue(label: "LogDispatcherTests")
        
        destination = LogDestinationMock()
        
        dispatcher = LogDispatcher(queue)
        fixedClockDispatcher = LogDispatcher(queue, { date })
        collector = destination.setUpCollector(testCase: self)
        
        self.date = date
    }
    
    func testLogDestinationsReceiveLogEntry1() {
        fixedClockDispatcher.add(destination)
        collector.expectedElementCount = 1
        
        fixedClockDispatcher.log(.debug, "123")
        
        collector.wait()
        
        XCTAssertEqual(collector.elements.count, 1)
        
        let entry = collector.elements[0]
        XCTAssertEqual(entry.date, date)
        XCTAssertEqual(entry.message.text, "123")
        XCTAssertEqual(entry.message.kind, .debug)
        XCTAssertTrue(entry.source?.file.hasSuffix("LogDispatcherTests.swift") ?? false)
        XCTAssertEqual(entry.source?.function, "testLogDestinationsReceiveLogEntry1()")
        XCTAssertEqual(entry.source?.line, 32)
    }
    
    func testLogDestinationsReceiveLogEntry2() {
        fixedClockDispatcher.add(destination)
        collector.expectedElementCount = 1
        
        let message = LogEntry.Message(text: "123", kind: .debug)
        let source = LogEntry.Source(file: "file", function: "func", line: 42)
        fixedClockDispatcher.log(message, source)
        
        collector.wait()
        
        XCTAssertEqual(collector.elements.count, 1)
        
        let entry = collector.elements[0]
        XCTAssertEqual(entry.date, date)
        XCTAssertEqual(entry.message.text, "123")
        XCTAssertEqual(entry.message.kind, .debug)
        XCTAssertEqual(entry.source?.file, "file")
        XCTAssertEqual(entry.source?.function, "func")
        XCTAssertEqual(entry.source?.line, 42)
    }
    
    func testLogDestinationThrowsError() {
        fixedClockDispatcher.add(destination)
        collector.expectedElementCount = 1
        
        var index = 0
        let error = TextError("Some Error")
        let c = collector
        destination.handler = { entry in
            index += 1
            if index == 1 {
                throw error
            } else {
                c?.add(entry)
            }
        }
        
        fixedClockDispatcher.log(.warning, "999")
        fixedClockDispatcher.log(.debug, "123")
        
        collector.wait()
        
        XCTAssertEqual(collector.elements.count, 1)
        
        let entry = collector.elements[0]
        XCTAssertEqual(entry.date, date)
        XCTAssertEqual(entry.message.text, "123")
        XCTAssertEqual(entry.message.kind, .debug)
        XCTAssertTrue(entry.source?.file.hasSuffix("LogDispatcherTests.swift") ?? false)
        XCTAssertEqual(entry.source?.function, "testLogDestinationThrowsError()")
        XCTAssertEqual(entry.source?.line, 85)
    }
    
    func testAsyncLogging() {
        dispatcher.add(destination)
        collector.expectedElementCount = 2
        
        destination.addDelay(0.5)
        
        let date1 = Date()
        dispatcher.log(.raw, "111", sync: false)
        dispatcher.log(.raw, "222", sync: false)
        let date2 = Date()
        
        collector.wait(timeout: 2)
        
        XCTAssertTrue(date2.timeIntervalSince(date1) < 0.5)
    }
    
    func testSyncLogging() {
        dispatcher.add(destination)
        collector.expectedElementCount = 2
        
        destination.addDelay(0.5)
        
        let date1 = Date()
        dispatcher.log(.raw, "111", sync: true)
        dispatcher.log(.raw, "222", sync: true)
        let date2 = Date()
        
        collector.wait(timeout: 2)
        
        XCTAssertTrue(date2.timeIntervalSince(date1) >= 1)
    }
    
    func testLoggingOrder() {
        dispatcher.add(destination)
        collector.expectedElementCount = 10
        
        dispatcher.log(.raw, "000", sync: true)
        dispatcher.log(.raw, "111", sync: false)
        dispatcher.log(.raw, "222", sync: true)
        dispatcher.log(.raw, "333", sync: false)
        dispatcher.log(.raw, "444", sync: true)
        dispatcher.log(.raw, "555", sync: false)
        dispatcher.log(.raw, "666", sync: true)
        dispatcher.log(.raw, "777", sync: false)
        dispatcher.log(.raw, "888", sync: true)
        dispatcher.log(.raw, "999", sync: false)
        
        collector.wait()
        
        XCTAssertEqual(collector.elements[0].message.text, "000")
        XCTAssertEqual(collector.elements[1].message.text, "111")
        XCTAssertEqual(collector.elements[2].message.text, "222")
        XCTAssertEqual(collector.elements[3].message.text, "333")
        XCTAssertEqual(collector.elements[4].message.text, "444")
        XCTAssertEqual(collector.elements[5].message.text, "555")
        XCTAssertEqual(collector.elements[6].message.text, "666")
        XCTAssertEqual(collector.elements[7].message.text, "777")
        XCTAssertEqual(collector.elements[8].message.text, "888")
        XCTAssertEqual(collector.elements[9].message.text, "999")
        
        XCTAssertTrue(collector.elements[0].date < collector.elements[1].date)
        XCTAssertTrue(collector.elements[1].date < collector.elements[2].date)
        XCTAssertTrue(collector.elements[2].date < collector.elements[3].date)
        XCTAssertTrue(collector.elements[3].date < collector.elements[4].date)
        XCTAssertTrue(collector.elements[4].date < collector.elements[5].date)
        XCTAssertTrue(collector.elements[5].date < collector.elements[6].date)
        XCTAssertTrue(collector.elements[6].date < collector.elements[7].date)
        XCTAssertTrue(collector.elements[7].date < collector.elements[8].date)
        XCTAssertTrue(collector.elements[8].date < collector.elements[9].date)
    }
    
    func testLogFiltering() {
        dispatcher.add(destination, [.debug, .info])
        collector.expectedElementCount = 2
        
        dispatcher.log(.debug, "debug", sync: true)
        dispatcher.log(.info, "info", sync: false)
        dispatcher.log(.error, "error", sync: true)
        dispatcher.log(.warning, "warning", sync: true)
        
        collector.wait()
        
        XCTAssertEqual(collector.elements.count, 2)
        XCTAssertEqual(collector.elements[0].message.text, "debug")
        XCTAssertEqual(collector.elements[1].message.text, "info")
    }
    
    func testLogIntoMultipleDestinations() {
        let destination2 = LogDestinationMock()
        let collector2 = destination2.setUpCollector(testCase: self)
        
        let destination3 = LogDestinationMock()
        let collector3 = destination3.setUpCollector(testCase: self)
        
        dispatcher.add(destination)
        dispatcher.add(destination2, [.debug])
        dispatcher.add(destination3, [.info])
        
        collector.expectedElementCount = 5
        collector2.expectedElementCount = 1
        collector3.expectedElementCount = 1
        
        dispatcher.log(.debug, "111")
        dispatcher.log(.error, "222")
        dispatcher.log(.fatal, "444")
        dispatcher.log(.info, "333")
        dispatcher.log(.raw, "555")
        
        collector.wait()
        collector2.wait()
        collector3.wait()
        
        XCTAssertEqual(collector.elements.count, 5)
        XCTAssertEqual(collector2.elements.count, 1)
        XCTAssertEqual(collector3.elements.count, 1)
    }
}
