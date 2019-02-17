import Foundation

public final class LogExporter {
    private let queue: DispatchQueue
    private let assembler: LogAssembler
    
    public init(_ queue: DispatchQueue, _ assembler: LogAssembler) {
        self.queue = queue
        self.assembler = assembler
    }
    
    public func export(fileName: String, completionHandler: @escaping (URL?, Error?) -> Void) {
        queue.async {
            do {
                let url = self.outputUrl(fileName: fileName)
                try self.assembler.assemble(at: url)
                completionHandler(url, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
    
    public func export(completionHandler: @escaping (Data?, Error?) -> Void) {
        let fileName = UUID().uuidString
        export(fileName: fileName) { url, error in
            if let url = url {
                do {
                    let data = try Data(contentsOf: url)
                    try? FileManager.default.removeItem(at: url)
                    completionHandler(data, nil)
                } catch {
                    completionHandler(nil, error)
                }
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    private func outputUrl(fileName: String) -> URL {
        return FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    }
}
