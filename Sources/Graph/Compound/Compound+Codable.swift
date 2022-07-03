import Foundation

extension Compound: Codable where InnerGraph: Codable, InnerTree: Codable {
    enum CodingKeys: String, CodingKey {
        case graph
        case tree
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(graph, forKey: .graph)
        try container.encode(tree, forKey: .tree)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let graph = try container.decode(InnerGraph.self, forKey: .graph)
        let tree = try container.decode(InnerTree.self, forKey: .tree)
        try self.init(graph: graph, tree: tree)
    }
}
