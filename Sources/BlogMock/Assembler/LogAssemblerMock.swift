import BLog

public final class LogAssemblerMock {
    public typealias Handler = (URL) throws -> Void
    public var handler: Handler?
    
    public init() {}
}

extension LogAssemblerMock: LogAssembler {
    public func assemble(at url: URL) throws {
        try handler?(url)
    }
}
