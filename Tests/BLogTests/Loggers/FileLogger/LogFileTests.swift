@testable import BLog
@testable import BLogMock
import XCTest

class LogFileTests: XCTestCase {
    private var fileUrl: URL!
    private var directory: Directory!
    private var configuration: FileLogConfiguration!
    
    override func setUp() {
        super.setUp()
        fileUrl = FileManager.default.temporaryDirectory.appendingPathComponent("123.txt")
        directory = Directory.uniqueTempDirectory()
        
        let fileSize = Int64(1_000_000)
        configuration = FileLogConfiguration(directoryUrl: directory.url, fileCount: 5, fileSize: fileSize)
        
        try? directory.createIfNeeded()
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: fileUrl)
        try? directory.remove()
        super.tearDown()
    }
    
    func testInitFileNotExist() {
        do {
            let _ = try LogFile(url: fileUrl)
            XCTFail()
        } catch {
            //
        }
    }
    
    func testInit() throws {
        FileManager.default.createFile(atPath: fileUrl.path, contents: Data("12345".utf8), attributes: nil)
        let file = try LogFile(url: fileUrl)
        XCTAssertEqual(file.url, fileUrl)
        XCTAssertEqual(file.size, 5)
    }
    
    func testReadData() throws {
        FileManager.default.createFile(atPath: fileUrl.path, contents: Data("12345".utf8), attributes: nil)
        let file = try LogFile(url: fileUrl)
        XCTAssertEqual(try file.readData(), Data("12345".utf8))
    }
    
    func testReadText() throws {
        FileManager.default.createFile(atPath: fileUrl.path, contents: Data("12345".utf8), attributes: nil)
        let file = try LogFile(url: fileUrl)
        XCTAssertEqual(try file.readText(), "12345")
    }
    
    func testExistingLogFiles() throws {
        XCTAssertTrue(try LogFile.existingLogFiles(for: configuration).isEmpty)
        
        _ = directory.createFile(name: "log0.txt", text: "123")
        _ = directory.createFile(name: "log1.txt", text: "123")
        
        let logFiles = try LogFile.existingLogFiles(for: configuration)
        XCTAssertEqual(logFiles.count, 2)
        XCTAssertEqual(logFiles[0].url, directory.url.appendingPathComponent("log0.txt"))
        XCTAssertEqual(logFiles[1].url, directory.url.appendingPathComponent("log1.txt"))
    }
    
    func testVacantLogFileUrls() throws {
        _ = directory.createFile(name: "log0.txt", text: "123")
        _ = directory.createFile(name: "log1.txt", text: "123")
        _ = directory.createFile(name: "log2.txt", text: "123")
        
        let urls = LogFile.vacantLogFileUrls(for: configuration)
        XCTAssertEqual(urls.count, 2)
        XCTAssertEqual(urls[0], directory.url.appendingPathComponent("log3.txt"))
        XCTAssertEqual(urls[1], directory.url.appendingPathComponent("log4.txt"))
    }
    
    func testSortedLogFilesByDate() throws {
        _ = directory.createFile(name: "log4.txt", text: "123")
        _ = directory.createFile(name: "log1.txt", text: "123")
        
        let logFiles = try LogFile.sortedLogFilesByDate(for: configuration)
        XCTAssertEqual(logFiles.count, 2)
        XCTAssertEqual(logFiles[0].url, directory.url.appendingPathComponent("log4.txt"))
        XCTAssertEqual(logFiles[1].url, directory.url.appendingPathComponent("log1.txt"))
    }
    
    func testNewestLogFile() throws {
        _ = directory.createFile(name: "log0.txt", text: "123")
        _ = directory.createFile(name: "log1.txt", text: "123")
        _ = directory.createFile(name: "log2.txt", text: "123")
        
        let logFiles = try LogFile.sortedLogFilesByDate(for: configuration)
        let logFile = LogFile.newestLogFile(from: logFiles)
        XCTAssertEqual(logFile?.url, directory.url.appendingPathComponent("log2.txt"))
    }
    
    func testOldestLogFile() throws {
        _ = directory.createFile(name: "log0.txt", text: "123")
        _ = directory.createFile(name: "log1.txt", text: "123")
        _ = directory.createFile(name: "log2.txt", text: "123")
        
        let logFiles = try LogFile.sortedLogFilesByDate(for: configuration)
        let logFile = LogFile.oldestLogFile(from: logFiles)
        XCTAssertEqual(logFile?.url, directory.url.appendingPathComponent("log0.txt"))
    }
    
    func testRecycledLogFile() throws {
        _ = directory.createFile(name: "log0.txt", text: "666")
        
        let logFiles = try LogFile.existingLogFiles(for: configuration)
        let logFile = logFiles[0]
        
        XCTAssertEqual(try logFile.readText(), "666")
        
        let recycled = try LogFile.recycledLogFile(logFile)
        XCTAssertEqual(recycled.url, logFile.url)
        XCTAssertEqual(try recycled.readText(), "")
    }
}
