import Foundation
import WolfBase
import SortedCollections

extension Graph: Codable where NodeID: Codable, EdgeID: Codable, NodeData: Codable & DefaultConstructable, EdgeData: Codable & DefaultConstructable, GraphData: Codable & DefaultConstructable {
    enum CodingKeys: CodingKey {
        case data
        case edges
        case nodes
    }

    struct EncodingEdge: Codable {
        let edge: Edge
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            try container.encode(edge.tail)
            try container.encode(edge.head)
            if EdgeData.self != Empty.self {
                try container.encode(edge.data)
            }
        }
        
        init(edge: Edge) {
            self.edge = edge
        }
            
        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            let tail = try container.decode(NodeID.self)
            let head = try container.decode(NodeID.self)
            let data: EdgeData
            if EdgeData.self == Empty.self {
                data = Empty() as! EdgeData
            } else {
                data = try container.decode(EdgeData.self)
            }
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

        if GraphData.self != Empty.self {
            try container.encode(data, forKey: .data)
        }
        
        if NodeData.self == Empty.self {
            let nodes: SortedSet<NodeID> = _nodes.reduce(into: []) { result, element in
                result.insert(element.key)
            }
            try container.encode(nodes, forKey: .nodes)
        } else {
            let nodes: Dictionary<NodeID, EncodingNode> = _nodes.reduce(into: .init()) { result, element in
                result[element.key] = EncodingNode(node: element.value)
            }
            try container.encode(nodes, forKey: .nodes)
        }

        let edges: Dictionary<EdgeID, EncodingEdge> = _edges.reduce(into: .init()) { result, element in
            result[element.key] = EncodingEdge(edge: element.value)
        }
        try container.encode(edges, forKey: .edges)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        var graph = Self()
        
        if GraphData.self != Empty.self {
            graph.data = try container.decode(GraphData.self, forKey: .data)
        }

        if NodeData.self == Empty.self {
            let nodes = try container.decode([NodeID].self, forKey: .nodes)
            try nodes.forEach {
                try graph.newNode($0)
            }
        } else {
            let nodes = try container.decode(Dictionary<NodeID, EncodingNode>.self, forKey: .nodes)
            try nodes.forEach {
                try graph.newNode($0.key, data: $0.value.node.data)
            }
        }

        let edges = try container.decode(Dictionary<EdgeID, EncodingEdge>.self, forKey: .edges)
        try edges.forEach {
            let edge = $0.value.edge
            try graph.newEdge($0.key, tail: edge.tail, head: edge.head, data: edge.data)
        }
        self = graph
    }
}
