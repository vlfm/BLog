import Foundation

/// Utility logger holder.
/// Providers global static access to logger.
public final class Log {
    public static var logger: Logger?
    public static var logExporter: LogExporter?
    
    public static func debug(_ message: String,
                             file: String = #file,
                             function: String = #function,
                             line: Int = #line,
                             sync: Bool = false) {
        log(.debug, message, file: file, function: function, line: line, sync: sync)
    }
    
    public static func error(_ message: String,
                             file: String = #file,
                             function: String = #function,
                             line: Int = #line,
                             sync: Bool = false) {
        log(.error, message, file: file, function: function, line: line, sync: sync)
    }
    
    public static func fatal(_ message: String,
                             file: String = #file,
                             function: String = #function,
                             line: Int = #line,
                             sync: Bool = false) {
        log(.fatal, message, file: file, function: function, line: line, sync: sync)
    }
    
    public static func info(_ message: String,
                            file: String = #file,
                            function: String = #function,
                            line: Int = #line,
                            sync: Bool = false) {
        log(.info, message, file: file, function: function, line: line, sync: sync)
    }
    
    public static func raw(_ message: String,
                           file: String = #file,
                           function: String = #function,
                           line: Int = #line,
                           sync: Bool = false) {
        log(.raw, message, file: file, function: function, line: line, sync: sync)
    }
    
    public static func verbose(_ message: String,
                               file: String = #file,
                               function: String = #function,
                               line: Int = #line,
                               sync: Bool = false) {
        log(.verbose, message, file: file, function: function, line: line, sync: sync)
    }
    
    public static func warning(_ message: String,
                               file: String = #file,
                               function: String = #function,
                               line: Int = #line,
                               sync: Bool = false) {
        log(.warning, message, file: file, function: function, line: line, sync: sync)
    }
    
    public static func export(fileName: String, completionHandler: @escaping (URL?, Error?) -> Void) {
        logExporter?.export(fileName: fileName, completionHandler: completionHandler)
    }
    
    public static func export(completionHandler: @escaping (Data?, Error?) -> Void) {
        logExporter?.export(completionHandler: completionHandler)
    }
    
    private static func log(_ messageKind: LogEntry.Message.Kind,
                            _ message: String,
                            file: String,
                            function: String,
                            line:Int,
                            sync: Bool) {
        let message = LogEntry.Message(text: message, kind: messageKind)
        let source = LogEntry.Source(file: file, function: function, line: line)
        logger?.log(message, source, sync: sync)
    }
}

extension Log {
    public static func error(_ error: Error,
                             file: String = #file,
                             function: String = #function,
                             line: Int = #line,
                             sync: Bool = false) {
        log(.error, error.localizedDescription, file: file, function: function, line: line, sync: sync)
    }
}

extension Log {
    public static func setUpDefault() throws {
        guard let directoryUrl = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask).first else {
                throw TextError("Failed to get application support directory")
        }
        
        let fileLogDirectoryUrl = directoryUrl.appendingPathComponent("Log")
        let fileLogConfiguration = FileLogConfiguration(directoryUrl: fileLogDirectoryUrl,
                                                        fileCount: 10,
                                                        fileSize: 500_000)
        
        let queue = DispatchQueue(label: "Logger")
        let (logger, logExporter) = LoggerFactory.make(queue, fileLogConfiguration)
        Log.logger = logger
        Log.logExporter = logExporter
    }
}
