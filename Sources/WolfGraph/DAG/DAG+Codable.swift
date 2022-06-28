import Foundation

extension DAG: Codable where InnerGraph: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(innerGraph)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let graph = try container.decode(InnerGraph.self)
        try self.init(innerGraph: graph)
    }
}
