import Foundation

public final class LoggerFactory {
    public static func make(_ queue: DispatchQueue,
                            _ fileLogConfiguration: FileLogConfiguration) -> (logger: Logger, logExporter: LogExporter) {
        let logger = LogDispatcher(queue)
        let consoleDestination = FormattedLogWriter(StandardLogEntryFormatter(.console),
                                                    ConsoleLogOutput())
        let fileDestination = FormattedLogWriter(StandardLogEntryFormatter(.file),
                                                 FileLogOutput(fileLogConfiguration))
        
        logger.add(consoleDestination)
        logger.add(fileDestination)
        
        let logExporter = LogExporter(queue, FileLogAssembler(fileLogConfiguration))
        
        return (logger, logExporter)
    }
}
