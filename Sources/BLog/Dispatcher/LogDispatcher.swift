import Foundation

public final class LogDispatcher {
    public typealias Clock = () -> Date
    public typealias Filter = (LogEntry) -> Bool
    
    private let queue: DispatchQueue
    private let clock: Clock
    
    private var destinations: [(destination: LogDestination, filter: Filter)] = []
    
    public init(_ queue: DispatchQueue, _ clock: @escaping Clock = { Date() }) {
        self.queue = queue
        self.clock = clock
    }
    
    public func add(_ destination: LogDestination, _ filter: @escaping Filter = { _ in return true }) {
        queue.async {
            let pair = (destination, filter)
            self.destinations.append(pair)
        }
    }
    
    public func add(_ destination: LogDestination, _ messageKinds: [LogEntry.Message.Kind]) {
        add(destination) { entry in
            return messageKinds.contains(entry.message.kind)
        }
    }
}

extension LogDispatcher: Logger {
    public func log(_ message: LogEntry.Message, _ source: LogEntry.Source?, sync: Bool) {
        execute(sync) {
            let entry = self.makeLogEntry(message, source)
            self.sendToDestinations(entry)
        }
    }
}

extension LogDispatcher {
    private func execute(_ sync: Bool, block: @escaping () -> Void) {
        if sync {
            queue.sync { block() }
        } else {
            queue.async { block() }
        }
    }
    
    private func makeLogEntry(_ message: LogEntry.Message, _ source: LogEntry.Source?) -> LogEntry {
        let date = clock()
        return LogEntry(date: date, message: message, source: source)
    }
    
    private func sendToDestinations(_ entry: LogEntry) {
        for pair in destinations {
            do {
                if pair.filter(entry) {
                    try pair.destination.receive(entry)
                }
            } catch {
                print("\(pair.destination): \(error)")
            }
        }
    }
}
