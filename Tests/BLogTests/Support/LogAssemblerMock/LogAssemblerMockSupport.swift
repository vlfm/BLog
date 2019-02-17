@testable import BLog
@testable import BLogMock
import XCTest

extension LogAssemblerMock {
    func setUpWriteHandler(text: String) {
        handler = { url in
            if let data = text.data(using: .utf8) {
                try data.write(to: url)
            }
        }
    }
}
