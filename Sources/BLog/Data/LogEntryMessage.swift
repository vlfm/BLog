import Foundation

extension LogEntry {
    public struct Message: Equatable {
        public let text: String
        public let kind: Kind
        
        public init(text: String, kind: Kind) {
            self.text = text
            self.kind = kind
        }
    }
}
