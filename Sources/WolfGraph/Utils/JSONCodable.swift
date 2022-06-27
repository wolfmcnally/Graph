import Foundation

fileprivate let jsonEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    return encoder
}()

fileprivate let jsonDecoder = JSONDecoder()

public protocol JSONCodable where Self: Codable {
    var json: String { get }
    init(json: String) throws
}

public extension JSONCodable {
    var json: String {
        try! jsonEncoder.encode(self).utf8!
    }

    init(json: String) throws {
        self = try jsonDecoder.decode(Self.self, from: json.utf8Data)
    }
}
