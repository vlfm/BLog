import Foundation

public protocol FormattedLogOutput {
    func receive(_ formattedLogEntry: String) throws
}
