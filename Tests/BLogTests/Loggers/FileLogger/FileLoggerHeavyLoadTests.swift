@testable import BLog
@testable import BLogMock
import XCTest

class FileLoggerHeavyLoadTests: XCTestCase {
    private var directory: Directory!
    private let queue = DispatchQueue(label: "FileLogOutputLoadTests")
    
    override func setUp() {
        super.setUp()
        directory = Directory.uniqueTempDirectory()
    }
    
    override func tearDown() {
        try? directory.remove()
        super.tearDown()
    }
    
    func testLogManyMessages() throws {
        let fileCount = 100
        let fileSize = Int64(100)
        
        let configuration = FileLogConfiguration(directoryUrl: directory.url,
                                                 fileCount: fileCount,
                                                 fileSize: fileSize)
        
        let output = FileLogOutput(configuration)
        
        let logger = LogDispatcher(queue)
        logger.add(FormattedLogWriter(StandardLogEntryFormatter(.file), output))
        
        try directory.createIfNeeded()
        XCTAssertEqual(try directory.contentsOfDirectory(), [])
        
        var messages: [String] = []
        
        let iterationsPerFile = fileSize / 10
        
        for _ in 0..<fileCount {
            let text10Bytes = String(UUID().uuidString.prefix(10))
            XCTAssertEqual(text10Bytes.data(using: .utf8)?.count, 10)
            
            messages.append(text10Bytes)
            
            for _ in 0..<iterationsPerFile {
                logger.log(.raw, text10Bytes)
            }
        }
        
        queue.sync {}
        
        let names = try directory.contentsOfDirectory()
        
        XCTAssertEqual(names.count, fileCount)
        
        let attributes = try directory.attributesOfItems().sorted { a, b in
            let dateA = a.1[.modificationDate] as! Date
            let dateB = b.1[.modificationDate] as! Date
            return dateA < dateB
        }
        
        XCTAssertEqual(attributes.count, fileCount)
        
        for i in 0..<fileCount {
            let message = messages[i]
            
            var expectedFileContent = ""
            
            for _ in 0..<iterationsPerFile {
                expectedFileContent += message + "\n"
            }
            
            let fileData = try Data(contentsOf: directory.url.appendingPathComponent(attributes[i].0))
            XCTAssertEqual(expectedFileContent.data(using: .utf8), fileData)
        }
    }
    
    func testPerformance1() {
        let fileCount = 10
        let fileSize = 1_000_000
        
        let configuration = FileLogConfiguration(directoryUrl: directory.url,
                                                 fileCount: fileCount,
                                                 fileSize: Int64(fileSize))
        
        let output = FileLogOutput(configuration)
        
        let logger = LogDispatcher(queue)
        logger.add(FormattedLogWriter(StandardLogEntryFormatter(.file), output))
        
        let message = String(repeating: "1234567890", count: 10)
        
        let messageSize = message.data(using: .utf8)!.count
        let iterations = fileCount * fileSize / messageSize
        
        measure {
            for _ in 0..<iterations {
                logger.log(.raw, message)
            }
            queue.sync {}
        }
    }
}
