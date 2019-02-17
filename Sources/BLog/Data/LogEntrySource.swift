import Foundation

extension LogEntry {
    public struct Source: Equatable {
        public let file: String
        public let function: String
        public let line: Int
        
        public init(file: String, function: String, line: Int) {
            self.file = file
            self.function = function
            self.line = line
        }
    }
}
