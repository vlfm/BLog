import Foundation

public final class FileLogAssembler {
    private let configuration: FileLogConfiguration
    
    public init(_ configuration: FileLogConfiguration) {
        self.configuration = configuration
    }
}

extension FileLogAssembler: LogAssembler {
    public func assemble(at url: URL) throws {
        let logFiles = try LogFile.sortedLogFilesByDate(for: configuration)
        
        if logFiles.isEmpty {
            throw TextError("Log not found for \(configuration)")
        }
        
        try LogFile.removeFileIfExist(at: url)
        try LogFile.createEmptyFileIfNotExist(at: url)
        
        let handle = try FileHandle(forWritingTo: url)
        
        defer {
            handle.closeFile()
        }
        
        handle.seekToEndOfFile()
        
        for logFile in logFiles {
            try autoreleasepool {
                let data = try logFile.readData()
                handle.write(data)
            }
        }
    }
}
