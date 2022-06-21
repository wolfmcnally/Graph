import Foundation
import WolfBase

fileprivate let jsonEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    return encoder
}()

fileprivate let jsonDecoder = JSONDecoder()

extension Graph: Codable {
    enum CodingKeys: CodingKey {
        case nodes
        case edges
    }

    struct EncodingEdge: Codable {
        let edge: Edge
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            try container.encode(edge.tail)
            try container.encode(edge.head)
            try container.encode(edge.data)
        }
        
        init(edge: Edge) {
            self.edge = edge
        }
            
        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            let tail = try container.decode(NodeID.self)
            let head = try container.decode(NodeID.self)
            let data = try container.decode(EdgeData.self)
            self.edge = Edge(tail: tail, head: head, data: data)
        }
    }
    
    struct EncodingNode: Codable {
        let node: Node
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(node.data)
        }
        
        init(node: Node) {
            self.node = node
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let data = try container.decode(NodeData.self)
            self.node = Node(data: data)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let nodes: Dictionary<NodeID, EncodingNode> = _nodes.reduce(into: .init()) { result, element in
            result[element.key] = EncodingNode(node: element.value)
        }
        try container.encode(nodes, forKey: .nodes)

        let edges: Dictionary<EdgeID, EncodingEdge> = _edges.reduce(into: .init()) { result, element in
            result[element.key] = EncodingEdge(edge: element.value)
        }
        try container.encode(edges, forKey: .edges)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let edges = try container.decode(Dictionary<EdgeID, EncodingEdge>.self, forKey: .edges)
        let nodes = try container.decode(Dictionary<NodeID, EncodingNode>.self, forKey: .nodes)
        var graph = Self()
        try nodes.forEach {
            graph = try graph.newNode($0.key, data: $0.value.node.data)
        }
        try edges.forEach {
            let edge = $0.value.edge
            graph = try graph.newEdge($0.key, tail: edge.tail, head: edge.head, data: edge.data)
        }
        self = graph
    }
    
    public var json: String {
        try! jsonEncoder.encode(self).utf8!
    }
    
    public init(json: String) throws {
        self = try jsonDecoder.decode(Self.self, from: json.utf8Data)
    }
}
