@testable import BLog
@testable import BLogMock
import XCTest

class FileLogConfigurationTests: XCTestCase {
    private let directoryUrl = FileManager.default.temporaryDirectory
    private let fileSize = Int64(100)
    
    func testLogFileUrlsZeroFilesConfiguration() {
        let configuration = FileLogConfiguration(directoryUrl: directoryUrl, fileCount: 0, fileSize: fileSize)
        XCTAssertTrue(configuration.logFileUrls.isEmpty)
    }
    
    func testLogFileUrls() {
        let configuration = FileLogConfiguration(directoryUrl: directoryUrl, fileCount: 5, fileSize: fileSize)
        let logFileUrls = configuration.logFileUrls
        XCTAssertEqual(logFileUrls.count, 5)
        XCTAssertEqual(logFileUrls[0], directoryUrl.appendingPathComponent("log0.txt"))
        XCTAssertEqual(logFileUrls[1], directoryUrl.appendingPathComponent("log1.txt"))
        XCTAssertEqual(logFileUrls[2], directoryUrl.appendingPathComponent("log2.txt"))
        XCTAssertEqual(logFileUrls[3], directoryUrl.appendingPathComponent("log3.txt"))
        XCTAssertEqual(logFileUrls[4], directoryUrl.appendingPathComponent("log4.txt"))
    }
}
