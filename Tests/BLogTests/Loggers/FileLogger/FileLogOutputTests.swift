@testable import BLog
@testable import BLogMock
import XCTest

class FileLogOutputTests: XCTestCase {
    private var directory: Directory!
    private var configuration: FileLogConfiguration!
    private var output: FileLogOutput!
    
    private let text10Bytes1 = "1234567890"
    private let text10Bytes2 = "0987654321"
    private let text10Bytes3 = "ABCDEFGHIJ"
    
    override func setUp() {
        super.setUp()
        
        directory = Directory.uniqueTempDirectory()
        configuration = FileLogConfiguration(directoryUrl: directory.url,
                                             fileCount: 5,
                                             fileSize: 50)
        
        output = FileLogOutput(configuration)
    }
    
    override func tearDown() {
        try? directory.remove()
        super.tearDown()
    }
    
    func testReceiveMessageWhenLogFileNotExist() throws {
        XCTAssertTrue(try LogFile.existingLogFiles(for: configuration).isEmpty)
        
        let message = "Hello, world!"
        try output.receive(message)
        
        XCTAssertFalse(try LogFile.existingLogFiles(for: configuration).isEmpty)
        
        let logFile = try LogFile.sortedLogFilesByDate(for: configuration)[0]
        XCTAssertEqual(try logFile.readText(), message + "\n")
    }
    
    func testReceiveMessageWhenLogFileExist() throws {
        let fileUrl = LogFile.vacantLogFileUrls(for: configuration)[0]
        
        try directory.createIfNeeded()
        _ = directory.createFile(name: fileUrl.lastPathComponent, text: "123")
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileUrl.path))
        
        try output.receive("456")
        
        let logFile = try LogFile.sortedLogFilesByDate(for: configuration)[0]
        XCTAssertEqual(try logFile.readText(), "123456\n")
    }
    
    func testReceiveMessageAppendsToLogFile() throws {
        try output.receive("111")
        try output.receive("222")
        try output.receive("333")
        
        let logFile = try LogFile.sortedLogFilesByDate(for: configuration)[0]
        XCTAssertEqual(try logFile.readText(), "111\n222\n333\n")
    }
    
    func testLogFilesRotation() throws {
        try output.receive(String(repeating: "1", count: 10))
        XCTAssertEqual(try LogFile.existingLogFiles(for: configuration).count, 1)
        
        try output.receive(String(repeating: "2", count: 10))
        try output.receive(String(repeating: "3", count: 10))
        try output.receive(String(repeating: "4", count: 10))
        try output.receive(String(repeating: "5", count: 10))
        XCTAssertEqual(try LogFile.existingLogFiles(for: configuration).count, 1)
        
        try output.receive(String(repeating: "6", count: 10))
        XCTAssertEqual(try LogFile.existingLogFiles(for: configuration).count, 2)
        
        let logFiles = try LogFile.sortedLogFilesByDate(for: configuration)
        
        XCTAssertEqual(try logFiles[0].readText(), String(repeating: "1", count: 10) + "\n"
            + String(repeating: "2", count: 10) + "\n"
            + String(repeating: "3", count: 10) + "\n"
            + String(repeating: "4", count: 10) + "\n"
            + String(repeating: "5", count: 10) + "\n")
        XCTAssertEqual(try logFiles[1].readText(), String(repeating: "6", count: 10) + "\n")
    }
    
    func testLogFilesRotationFullCycle() throws {
        try output.receive(String(repeating: "1", count: 10))
        try output.receive(String(repeating: "2", count: 10))
        try output.receive(String(repeating: "3", count: 10))
        try output.receive(String(repeating: "4", count: 10))
        try output.receive(String(repeating: "5", count: 10))
        
        try output.receive(String(repeating: "6", count: 10))
        try output.receive(String(repeating: "7", count: 10))
        try output.receive(String(repeating: "8", count: 10))
        try output.receive(String(repeating: "9", count: 10))
        try output.receive(String(repeating: "0", count: 10))
        
        try output.receive(String(repeating: "A", count: 10))
        try output.receive(String(repeating: "B", count: 10))
        try output.receive(String(repeating: "C", count: 10))
        try output.receive(String(repeating: "D", count: 10))
        try output.receive(String(repeating: "E", count: 10))
        
        try output.receive(String(repeating: "F", count: 10))
        try output.receive(String(repeating: "G", count: 10))
        try output.receive(String(repeating: "H", count: 10))
        try output.receive(String(repeating: "I", count: 10))
        try output.receive(String(repeating: "J", count: 10))
        
        try output.receive(String(repeating: "K", count: 10))
        try output.receive(String(repeating: "L", count: 10))
        try output.receive(String(repeating: "M", count: 10))
        try output.receive(String(repeating: "N", count: 10))
        try output.receive(String(repeating: "O", count: 10))
        
        XCTAssertEqual(try LogFile.existingLogFiles(for: configuration).count, 5)
        
        let logFiles1 = try LogFile.sortedLogFilesByDate(for: configuration)
        
        XCTAssertEqual(try logFiles1[0].readText(), String(repeating: "1", count: 10) + "\n"
            + String(repeating: "2", count: 10) + "\n"
            + String(repeating: "3", count: 10) + "\n"
            + String(repeating: "4", count: 10) + "\n"
            + String(repeating: "5", count: 10) + "\n")
        
        XCTAssertEqual(try logFiles1[1].readText(), String(repeating: "6", count: 10) + "\n"
            + String(repeating: "7", count: 10) + "\n"
            + String(repeating: "8", count: 10) + "\n"
            + String(repeating: "9", count: 10) + "\n"
            + String(repeating: "0", count: 10) + "\n")
        
        XCTAssertEqual(try logFiles1[2].readText(), String(repeating: "A", count: 10) + "\n"
            + String(repeating: "B", count: 10) + "\n"
            + String(repeating: "C", count: 10) + "\n"
            + String(repeating: "D", count: 10) + "\n"
            + String(repeating: "E", count: 10) + "\n")
        
        XCTAssertEqual(try logFiles1[3].readText(), String(repeating: "F", count: 10) + "\n"
            + String(repeating: "G", count: 10) + "\n"
            + String(repeating: "H", count: 10) + "\n"
            + String(repeating: "I", count: 10) + "\n"
            + String(repeating: "J", count: 10) + "\n")
        
        XCTAssertEqual(try logFiles1[4].readText(), String(repeating: "K", count: 10) + "\n"
            + String(repeating: "L", count: 10) + "\n"
            + String(repeating: "M", count: 10) + "\n"
            + String(repeating: "N", count: 10) + "\n"
            + String(repeating: "O", count: 10) + "\n")
        
        try output.receive(String(repeating: "Z", count: 10))
        
        XCTAssertEqual(try LogFile.existingLogFiles(for: configuration).count, 5)
        
        let logFiles2 = try LogFile.sortedLogFilesByDate(for: configuration)
        
        XCTAssertEqual(try logFiles2[0].readText(), String(repeating: "6", count: 10) + "\n"
            + String(repeating: "7", count: 10) + "\n"
            + String(repeating: "8", count: 10) + "\n"
            + String(repeating: "9", count: 10) + "\n"
            + String(repeating: "0", count: 10) + "\n")
        
        XCTAssertEqual(try logFiles2[1].readText(), String(repeating: "A", count: 10) + "\n"
            + String(repeating: "B", count: 10) + "\n"
            + String(repeating: "C", count: 10) + "\n"
            + String(repeating: "D", count: 10) + "\n"
            + String(repeating: "E", count: 10) + "\n")
        
        XCTAssertEqual(try logFiles2[2].readText(), String(repeating: "F", count: 10) + "\n"
            + String(repeating: "G", count: 10) + "\n"
            + String(repeating: "H", count: 10) + "\n"
            + String(repeating: "I", count: 10) + "\n"
            + String(repeating: "J", count: 10) + "\n")
        
        XCTAssertEqual(try logFiles2[3].readText(), String(repeating: "K", count: 10) + "\n"
            + String(repeating: "L", count: 10) + "\n"
            + String(repeating: "M", count: 10) + "\n"
            + String(repeating: "N", count: 10) + "\n"
            + String(repeating: "O", count: 10) + "\n")
        
        XCTAssertEqual(try logFiles2[4].readText(), String(repeating: "Z", count: 10) + "\n")
    }
}
