@testable import BLog
@testable import BLogMock
import XCTest

class LogTests: XCTestCase {
    var logger: LoggerMock!
    var exporter: LogExporter!
    var assembler: LogAssemblerMock!
    
    override func setUp() {
        super.setUp()
        
        logger = LoggerMock()
        assembler = LogAssemblerMock()
        exporter = LogExporter(DispatchQueue(label: "LogExporter"), assembler)
        
        Log.logger = logger
        Log.logExporter = exporter
    }
}
