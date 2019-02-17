import Foundation

final class Directory {
    let url: URL
    
    static func uniqueTempDirectory() -> Directory {
        let directiryName = UUID().uuidString
        let directiryUrl = FileManager.default.temporaryDirectory.appendingPathComponent(directiryName)
        return Directory(url: directiryUrl)
    }
    
    init(url: URL) {
        self.url = url
    }
    
    func createIfNeeded() throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
    
    func remove() throws {
        try FileManager.default.removeItem(at: url)
    }
    
    func createFile(name: String, contents: Data) -> URL {
        let fileUrl = url.appendingPathComponent(name)
        FileManager.default.createFile(atPath: fileUrl.path, contents: contents, attributes: nil)
        return fileUrl
    }
    
    func createFile(name: String, text: String) -> URL {
        let data = Data(text.utf8)
        return createFile(name: name, contents: data)
    }
    
    func contentsOfDirectory() throws -> [String] {
        return try FileManager.default.contentsOfDirectory(atPath: url.path)
    }
    
    func attributesOfItems() throws -> [(String, [FileAttributeKey: Any])] {
        let names = try contentsOfDirectory()
        let urls = names.map { url.appendingPathComponent($0) }
        return try urls.map {
            return ($0.lastPathComponent, try FileManager.default.attributesOfItem(atPath: $0.path))
        }
    }
}
