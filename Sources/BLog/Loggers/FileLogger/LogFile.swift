import Foundation

struct LogFile {
    let url: URL
    let date: Date
    let size: Int64
    
    init(url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw TextError("Log file not exist at \(url)")
        }
        
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        
        guard let date = attributes[FileAttributeKey.modificationDate] as? Date else {
            throw TextError("ModificationDate not available for \(url)")
        }
        
        guard let bytes = attributes[FileAttributeKey.size] as? Int64 else {
            throw TextError("Size not available for \(url)")
        }
        
        self.url = url
        self.date = date
        self.size = bytes
    }
}

extension LogFile {
    func readData() throws -> Data {
        return try Data(contentsOf: url)
    }
    
    func readText() throws -> String {
        return try String(contentsOf: url)
    }
}

extension LogFile {
    static func existingLogFiles(for configuration: FileLogConfiguration) throws -> [LogFile] {
        let logFileUrls = configuration.logFileUrls.filter { FileManager.default.fileExists(atPath: $0.path) }
        return try logFileUrls.map(LogFile.init)
    }
    
    static func vacantLogFileUrls(for configuration: FileLogConfiguration) -> [URL] {
        let logFileUrls = configuration.logFileUrls
        return logFileUrls.filter { FileManager.default.fileExists(atPath: $0.path) == false }
    }
    
    static func sortedLogFilesByDate(for configuration: FileLogConfiguration) throws -> [LogFile] {
        let logFiles = try existingLogFiles(for: configuration)
        return sortedLogFilesByDate(logFiles)
    }
}

extension LogFile {
    static func newestLogFile(from logFiles: [LogFile]) -> LogFile? {
        return sortedLogFilesByDate(logFiles).last
    }
    
    static func oldestLogFile(from logFiles: [LogFile]) -> LogFile? {
        return sortedLogFilesByDate(logFiles).first
    }
    
    static func sortedLogFilesByDate(_ logFiles: [LogFile]) -> [LogFile] {
        return logFiles.sorted {
            return $0.date < $1.date
        }
    }
}

extension LogFile {
    static func recycledLogFile(_ logFile: LogFile) throws -> LogFile {
        return try recycledLogFile(at: logFile.url)
    }
    
    static func recycledLogFile(at url: URL) throws -> LogFile {
        try removeFileIfExist(at: url)
        try createEmptyFileIfNotExist(at: url)
        return try LogFile(url: url)
    }
}

extension LogFile {
    static func removeFileIfExist(at url: URL)  throws {
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
    
    static func createEmptyFileIfNotExist(at url: URL) throws {
        if FileManager.default.fileExists(atPath: url.path) == false {
            let created = FileManager.default.createFile(atPath: url.path, contents: Data(), attributes: nil)
            if created == false {
                throw TextError("Failed to create file at \(url)")
            }
        }
    }
}
