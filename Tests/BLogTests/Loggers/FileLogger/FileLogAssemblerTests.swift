@testable import BLog
@testable import BLogMock
import XCTest

class FileLogAssemblerTests: XCTestCase {
    private var directory: Directory!
    
    private var configuration0: FileLogConfiguration!
    private var configuration1: FileLogConfiguration!
    private var configuration5: FileLogConfiguration!
    
    private var outputUrl: URL!
    
    override func setUp() {
        super.setUp()
        
        directory = Directory.uniqueTempDirectory()
        
        let fileSize = Int64(1_000_000)
        configuration0 = FileLogConfiguration(directoryUrl: directory.url, fileCount: 0, fileSize: fileSize)
        configuration1 = FileLogConfiguration(directoryUrl: directory.url, fileCount: 1, fileSize: fileSize)
        configuration5 = FileLogConfiguration(directoryUrl: directory.url, fileCount: 5, fileSize: fileSize)
        
        outputUrl = directory.url.appendingPathComponent("output.txt")
    }
    
    override func tearDown() {
        try? directory.remove()
        super.tearDown()
    }
    
    func testAssembleConfiguration0() {
        let assembler = FileLogAssembler(configuration0)
        
        do {
            try assembler.assemble(at: outputUrl)
            XCTFail()
        } catch {
            //
        }
    }
    
    func testAssembleConfiguration1LogFileNotExist() {
        let assembler = FileLogAssembler(configuration1)
        
        do {
            try assembler.assemble(at: outputUrl)
            XCTFail()
        } catch {
            //
        }
    }
    
    func testAssembleConfiguration1() throws {
        let assembler = FileLogAssembler(configuration1)
        
        let fileName = LogFile.vacantLogFileUrls(for: configuration1)[0].lastPathComponent
        try directory.createIfNeeded()
        _ = directory.createFile(name: fileName, text: "Hello, world")
        
        try assembler.assemble(at: outputUrl)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputUrl.path))
        
        let logFile = try LogFile(url: outputUrl)
        
        XCTAssertEqual(try logFile.readText(), "Hello, world")
    }
    
    func testAssembleConfiguration5LogFileNotExist() {
        let assembler = FileLogAssembler(configuration5)
        
        do {
            try assembler.assemble(at: outputUrl)
            XCTFail()
        } catch {
            //
        }
    }
    
    func testAssembleConfiguration5() throws {
        let assembler = FileLogAssembler(configuration5)
        
        try directory.createIfNeeded()
        
        let fileName0 = LogFile.vacantLogFileUrls(for: configuration5)[0].lastPathComponent
        let fileName1 = LogFile.vacantLogFileUrls(for: configuration5)[1].lastPathComponent
        let fileName2 = LogFile.vacantLogFileUrls(for: configuration5)[2].lastPathComponent
        let fileName3 = LogFile.vacantLogFileUrls(for: configuration5)[3].lastPathComponent
        let fileName4 = LogFile.vacantLogFileUrls(for: configuration5)[4].lastPathComponent
        
        _ = directory.createFile(name: fileName0, text: "Hello, world 0")
        _ = directory.createFile(name: fileName1, text: "Hello, world 1")
        _ = directory.createFile(name: fileName2, text: "Hello, world 2")
        _ = directory.createFile(name: fileName3, text: "Hello, world 3")
        _ = directory.createFile(name: fileName4, text: "Hello, world 4")
        
        try assembler.assemble(at: outputUrl)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputUrl.path))
        
        let logFile = try LogFile(url: outputUrl)
        let expectedText = ""
            + "Hello, world 0"
            + "Hello, world 1"
            + "Hello, world 2"
            + "Hello, world 3"
            + "Hello, world 4"
        
        XCTAssertEqual(try logFile.readText(), expectedText)
    }
}
