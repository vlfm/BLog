@testable import BLog
@testable import BLogMock
import XCTest

class LogLoggingTests: LogTests {
    private var collector: Collector<(LogEntry.Message, LogEntry.Source?, Bool)>!
    
    override func setUp() {
        super.setUp()
        collector = logger.setUpCollector(testCase: self)
    }
    
    func testDebugAsync() {
        Log.debug("Hello, debug!")
        assertLogged("Hello, debug!", .debug, line: 14, sync: false)
    }
    
    func testDebugSync() {
        Log.debug("Hello, debug!", sync: true)
        assertLogged("Hello, debug!", .debug, line: 19, sync: true)
    }
    
    func testErrorAsync() {
        Log.error("Hello, error!")
        assertLogged("Hello, error!", .error, line: 24, sync: false)
    }
    
    func testErrorSync() {
        Log.error("Hello, error!", sync: true)
        assertLogged("Hello, error!", .error, line: 29, sync: true)
    }
    
    func testFatalAsync() {
        Log.fatal("Hello, fatal!")
        assertLogged("Hello, fatal!", .fatal, line: 34, sync: false)
    }
    
    func testFatalSync() {
        Log.fatal("Hello, fatal!", sync: true)
        assertLogged("Hello, fatal!", .fatal, line: 39, sync: true)
    }
    
    func testInfoAsync() {
        Log.info("Hello, info!")
        assertLogged("Hello, info!", .info, line: 44, sync: false)
    }
    
    func testInfoSync() {
        Log.info("Hello, info!", sync: true)
        assertLogged("Hello, info!", .info, line: 49, sync: true)
    }
    
    func testRawAsync() {
        Log.raw("Hello, raw!")
        assertLogged("Hello, raw!", .raw, line: 54, sync: false)
    }
    
    func testRawSync() {
        Log.raw("Hello, raw!", sync: true)
        assertLogged("Hello, raw!", .raw, line: 59, sync: true)
    }
    
    func testVerboseAsync() {
        Log.verbose("Hello, verbose!")
        assertLogged("Hello, verbose!", .verbose, line: 64, sync: false)
    }
    
    func testVerboseSync() {
        Log.verbose("Hello, verbose!", sync: true)
        assertLogged("Hello, verbose!", .verbose, line: 69, sync: true)
    }
    
    func testWarningAsync() {
        Log.warning("Hello, warning!")
        assertLogged("Hello, warning!", .warning, line: 74, sync: false)
    }
    
    func testWarningSync() {
        Log.warning("Hello, warning!", sync: true)
        assertLogged("Hello, warning!", .warning, line: 79, sync: true)
    }
}

extension LogLoggingTests {
    private func assertLogged(_ text: String, _ kind: LogEntry.Message.Kind, line: Int, sync: Bool) {
        collector.wait()
        
        XCTAssertEqual(collector.elements.count, 1)
        
        let record = collector.elements[0]
        
        XCTAssertEqual(record.0.text, text)
        XCTAssertEqual(record.0.kind, kind)
        XCTAssertEqual(record.2, sync)
        
        XCTAssertNotNil(record.1)
        
        if let source = record.1 {
            let fileUrl = URL(string: source.file)
            XCTAssertEqual(fileUrl?.lastPathComponent, "LogLoggingTests.swift")
            XCTAssertEqual(source.line, line)
        }
    }
}
