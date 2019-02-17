import Foundation

public protocol LogAssembler {
    func assemble(at url: URL) throws
}
