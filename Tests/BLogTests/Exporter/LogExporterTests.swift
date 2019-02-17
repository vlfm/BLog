@testable import BLog
@testable import BLogMock
import XCTest

class LogExporterTests: XCTestCase {
    private var assembler: LogAssemblerMock!
    private var exporter: LogExporter!
    private let fileName = "log.txt"
    
    override func setUp() {
        super.setUp()
        let queue = DispatchQueue(label: "FileLogExporterTests")
        assembler = LogAssemblerMock()
        exporter = LogExporter(queue, assembler)
    }
    
    func testExportAtFile() throws {
        assembler.setUpWriteHandler(text: "12345")
        
        let expectation = self.expectation(description: "testExportAtFile")
        
        exporter.export(fileName: fileName) { url, error in
            XCTAssertNil(error)
            XCTAssertNotNil(url)
            
            if let url = url , let content = try? String(contentsOf: url) {
                XCTAssertEqual(content, "12345")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testExportAtFileAssemblerThrowsError() {
        let expectedError = TextError("Some Error")
        assembler.handler = { _ in throw expectedError }
        
        let expectation = self.expectation(description: "testExportAtFileAssemblerThrowsError")
        
        exporter.export(fileName: fileName) { url, error in
            XCTAssertNil(url)
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? TextError, expectedError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testExportAsData() {
        assembler.setUpWriteHandler(text: "12345")
        
        let expectation = self.expectation(description: "testExportAsData")
        
        exporter.export { data, error in
            XCTAssertNil(error)
            XCTAssertNotNil(data)
            
            if let data = data {
                XCTAssertEqual(String(data: data, encoding: .utf8), "12345")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testExportAsDataAssemblerThrowsError() {
        let expectedError = TextError("Some Error")
        assembler.handler = { _ in throw expectedError }
        
        let expectation = self.expectation(description: "testExportAsDataAssemblerThrowsError")
        
        exporter.export { data, error in
            XCTAssertNil(data)
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? TextError, expectedError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
}
