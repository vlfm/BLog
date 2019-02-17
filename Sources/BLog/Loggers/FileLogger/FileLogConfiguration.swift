import Foundation

public struct FileLogConfiguration {
    public let directoryUrl: URL
    public let fileCount: Int
    public let fileSize: Int64
    
    public init(directoryUrl: URL, fileCount: Int, fileSize: Int64) {
        self.directoryUrl = directoryUrl
        self.fileCount = fileCount
        self.fileSize = fileSize
    }
}

extension FileLogConfiguration {
    var logFileUrls: [URL] {
        let names = (0..<fileCount).map { number in
            return "log\(number).txt"
        }
        return names.map { name in
            return directoryUrl.appendingPathComponent(name)
        }
    }
}

extension FileLogConfiguration: CustomStringConvertible {
    public var description: String {
        return "\(directoryUrl) \(fileCount) files \(fileSize) bytes each"
    }
}
