import Foundation
import WolfBase

extension Tree: Codable where InnerGraph: Codable, NodeID: Codable {
    enum CodingKeys: String, CodingKey {
        case graph
        case root
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(innerGraph, forKey: .graph)
        try container.encode(root, forKey: .root)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let root = try container.decode(NodeID.self, forKey: .root)
        let graph = try container.decode(InnerGraph.self, forKey: .graph)
        try self.init(innerGraph: graph, root: root)
    }
}

//extension Tree: JSONCodable where InnerGraph: Codable, NodeID: Codable {
//}
