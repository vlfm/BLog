import Foundation

public final class FileLogOutput {
    private let configuration: FileLogConfiguration
    
    private var file: UnsafeMutablePointer<FILE>?
    private var size: Int64 = 0
    
    public init(_ configuration: FileLogConfiguration) {
        self.configuration = configuration
    }
}

extension FileLogOutput: FormattedLogOutput {
    public func receive(_ formattedLogEntry: String) throws {
        let file = try openFileIfNeeded()
        
        let message = formattedLogEntry + "\n"
        fputs(message, file)
        fflush(file)
        
        if let count = message.data(using: .utf8)?.count {
            size += Int64(count)
        }
        
        try checkError(in: file)
    }
}

extension FileLogOutput {
    private func openFileIfNeeded() throws -> UnsafeMutablePointer<FILE> {
        if let file = file, size < configuration.fileSize {
            return file
        }
        
        if let file = file {
            fclose(file)
        }
        
        let logFile = try selectLogFile()
        
        guard let file = fopen(logFile.url.path, "a") else {
            throw TextError("Failed to open log file at \(logFile.url)")
        }
        
        self.file = file
        size = logFile.size
        
        return file
    }
    
    private func selectLogFile() throws -> LogFile {
        try createLogDirectoryIfNeeded()
        
        let logFiles = try LogFile.existingLogFiles(for: configuration)
        
        if let logFile = LogFile.newestLogFile(from: logFiles), logFile.size < configuration.fileSize {
            return logFile
        }
        
        let vacantUrls = LogFile.vacantLogFileUrls(for: configuration)
        
        if let vacantUrl = vacantUrls.first {
            return try LogFile.recycledLogFile(at: vacantUrl)
        }
        
        if let logFile = LogFile.oldestLogFile(from: logFiles) {
            return try LogFile.recycledLogFile(logFile)
        }
        
        throw TextError("Log file not available for \(configuration)")
    }
    
    private func createLogDirectoryIfNeeded() throws {
        if FileManager.default.fileExists(atPath: configuration.directoryUrl.path) == false {
            try FileManager.default.createDirectory(at: configuration.directoryUrl,
                                                    withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    private func checkError(in file: UnsafeMutablePointer<FILE>) throws {
        let code = ferror(file)
        if code != 0 {
            throw TextError("Error (ferror) \(code)")
        }
    }
}
