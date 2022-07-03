import Foundation
import WolfBase

extension Tree: Codable where InnerGraph: Codable, NodeID: Codable {
    enum CodingKeys: String, CodingKey {
        case root
    }

    public func encode(to encoder: Encoder) throws {
        try graph.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(root, forKey: .root)
    }
    
    public init(from decoder: Decoder) throws {
        let graph = try InnerGraph.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let root = try container.decode(NodeID.self, forKey: .root)
        try self.init(graph: graph, root: root)
    }
}
