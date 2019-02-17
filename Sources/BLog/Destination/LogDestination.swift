import Foundation

public protocol LogDestination {
    func receive(_ entry: LogEntry) throws
}
