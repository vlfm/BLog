import XCTest

final class Collector<Element> {
    private unowned let testCase: XCTestCase
    private let expectation: XCTestExpectation
    private var _elements: [Element] = []
    private let lock = NSRecursiveLock()
    
    var elements: [Element] {
        lock.lock()
        let e = _elements
        lock.unlock()
        return e
    }
    
    var expectedElementCount: Int {
        get {
            return expectation.expectedFulfillmentCount
        }
        set {
            expectation.expectedFulfillmentCount = newValue
        }
    }
    
    init(testCase: XCTestCase) {
        self.testCase = testCase
        expectation = testCase.expectation(description: "Collect Expectation")
    }
    
    func add(_ element: Element) {
        lock.lock()
        _elements.append(element)
        lock.unlock()
        expectation.fulfill()
    }
    
    func wait(timeout: TimeInterval = 1) {
        testCase.wait(for: [expectation], timeout: timeout)
    }
}
