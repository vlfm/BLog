import Foundation

public final class StandardLogEntryFormatter {
    private let configuration: Configuration
    private let dateFormatter: DateFormatter
    
    public init(_ configuration: Configuration = Configuration()) {
        self.configuration = configuration
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = configuration.dateFormat
    }
}

extension StandardLogEntryFormatter: LogEntryFormatter {
    public func format(_ entry: LogEntry) -> String {
        if entry.message.kind == .raw {
            return formatRaw(entry)
        }
        return formatNormal(entry)
    }
}

extension StandardLogEntryFormatter {
    private func formatRaw(_ entry: LogEntry) -> String {
        return entry.message.text
    }
    
    private func formatNormal(_ entry: LogEntry) -> String {
        var string = ""
        string += formatDate(entry)
        string += configuration.separator
        string += configuration.messageKindFormatter(entry.message.kind)
        string += configuration.separator
        
        if configuration.shouldIncludeSource, let source = formatSource(entry) {
            string += source
            string += configuration.separator
        }
        
        string += entry.message.text
        return string
    }
    
    private func formatDate(_ entry: LogEntry) -> String {
        return dateFormatter.string(from: entry.date)
    }
}

extension StandardLogEntryFormatter {
    public struct Configuration {
        public typealias MessageKindFormatter = (LogEntry.Message.Kind) -> String
        
        public var dateFormat = "dd/MM/yyyy HH:mm:ss.SSS"
        public var messageKindFormatter: MessageKindFormatter
        public var separator = " | "
        public var shouldIncludeSource = false
        
        public init() {
            messageKindFormatter = { kind in
                switch kind {
                case .debug: return "Debug"
                case .error: return "Error"
                case .fatal: return "Fatal"
                case .info: return "Info"
                case .raw: return "-"
                case .verbose: return "Verbose"
                case .warning: return "Warning"
                }
            }
        }
    }
}

extension StandardLogEntryFormatter.Configuration {
    public static var console: StandardLogEntryFormatter.Configuration {
        var configuration = StandardLogEntryFormatter.Configuration()
        configuration.dateFormat = "HH:mm:ss.SSS"
        configuration.messageKindFormatter = { kind in
            switch kind {
            case .debug: return "◼️"
            case .error: return "❌"
            case .fatal: return "💀"
            case .info: return "🔷"
            case .raw: return "-"
            case .verbose: return "◻️"
            case .warning: return "⚠️"
            }
        }
        return configuration
    }
    
    public static var file: StandardLogEntryFormatter.Configuration {
        return StandardLogEntryFormatter.Configuration()
    }
}
