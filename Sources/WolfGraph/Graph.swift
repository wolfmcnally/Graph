import Foundation

public struct Graph<NodeID, EdgeID, NodeData, EdgeData>
where NodeID: ElementID, EdgeID: ElementID
{
    private var _nodes: [NodeID: Node] = [:]
    private var _edges: [EdgeID: Edge] = [:]
    
    public init() { }
    
    public var nodesCount: Int {
        _nodes.count
    }
    
    public var nodes: some Sequence<NodeID> {
        _nodes.keys
    }
    
    public var edges: some Sequence<EdgeID> {
        _edges.keys
    }
    
    public var isEmpty: Bool {
        nodesCount == 0
    }

    public func nodeData(_ nodeID: NodeID) throws -> NodeData {
        try node(nodeID).data
    }
    
    public func nodeOutEdges(_ nodeID: NodeID) throws -> Set<EdgeID> {
        try node(nodeID).outEdges
    }
    
    public func nodeInEdges(_ nodeID: NodeID) throws -> Set<EdgeID> {
        try node(nodeID).inEdges
    }
    
    public func nodeEdges(_ nodeID: NodeID) throws -> Set<EdgeID> {
        try nodeOutEdges(nodeID).union(nodeInEdges(nodeID))
    }
    
    public func nodeOutEdgesCount(_ nodeID: NodeID) throws -> Int {
        try nodeOutEdges(nodeID).count
    }
    
    public func nodeInEdgesCount(_ nodeID: NodeID) throws -> Int {
        try nodeInEdges(nodeID).count
    }
    
    public func nodeEdgesCount(_ nodeID: NodeID) throws -> Int {
        try nodeEdges(nodeID).count
    }
    
    public func nodeSuccessors(_ nodeID: NodeID) throws -> [NodeID] {
        try nodeOutEdges(nodeID).map(edgeHead)
    }
    
    public func nodePredecessors(_ nodeID: NodeID) throws -> [NodeID] {
        try nodeInEdges(nodeID).map(edgeTail)
    }
    
    public func nodeNeighbors(_ nodeID: NodeID) throws -> Set<NodeID> {
        let successors = try nodeSuccessors(nodeID)
        let predececessors = try nodePredecessors(nodeID)
        return Set(successors).union(Set(predececessors))
    }

    public var edgesCount: Int {
        _edges.count
    }
    
    public func edgeData(_ edgeID: EdgeID) throws -> EdgeData {
        try edge(edgeID).data
    }
    
    public func edgeHead(_ edgeID: EdgeID) throws -> NodeID {
        try edge(edgeID).head
    }

    public func edgeTail(_ edgeID: EdgeID) throws -> NodeID {
        try edge(edgeID).tail
    }
}

extension Graph {
    public func withNodeData(_ nodeID: NodeID, transform: (inout NodeData) -> Void) throws -> Self {
        try checkHasNode(nodeID)
        var copy = self
        transform(&copy._nodes[nodeID]!.data)
        return copy
    }

    public func setNodeData(_ nodeID: NodeID, _ data: NodeData) throws -> Self {
        try withNodeData(nodeID) {
            $0 = data
        }
    }

    public func withEdgeData(_ edgeID: EdgeID, transform: (inout EdgeData) -> Void) throws -> Self {
        try checkHasEdge(edgeID)
        var copy = self
        transform(&copy._edges[edgeID]!.data)
        return copy
    }

    public func setEdgeData(_ edgeID: EdgeID, _ data: EdgeData) throws -> Self {
        try withEdgeData(edgeID) {
            $0 = data
        }
    }

    public func newNode(_ nodeID: NodeID, _ data: NodeData) throws -> Self {
        try checkHasNoNode(nodeID)
        var copy = self
        copy._nodes[nodeID] = Node(data: data)
        return copy
    }
    
    public func removeNode(_ nodeID: NodeID) throws -> Self {
        var copy = try removeNodeEdges(nodeID)
        copy._nodes.removeValue(forKey: nodeID)
        return copy
    }

    public func newEdge(_ edgeID: EdgeID, _ tailID: NodeID, _ headID: NodeID, _ data: EdgeData) throws -> Self {
        try checkHasNoEdge(edgeID)
        try checkHasNode(tailID)
        try checkHasNode(headID)
        
        var copy = self
        copy._edges[edgeID] = Edge(tail: tailID, head: headID, data: data)
        copy._nodes[tailID]!.outEdges.insert(edgeID)
        copy._nodes[headID]!.inEdges.insert(edgeID)
        return copy
    }
    
    public func removeEdge(_ edgeID: EdgeID) throws -> Self {
        let edge = try edge(edgeID)
        var copy = self
        copy._nodes[edge.tail]!.outEdges.remove(edgeID)
        copy._nodes[edge.head]!.inEdges.remove(edgeID)
        copy._edges.removeValue(forKey: edgeID)
        return copy
    }

    public func removeNodeEdges(_ nodeID: NodeID) throws -> Self {
        var copy = self
        try nodeEdges(nodeID).forEach {
            copy = try! copy.removeEdge($0)
        }
        return copy
    }
    
    public func moveEdge(_ edgeID: EdgeID, newTail: NodeID, newHead: NodeID) throws -> Self {
        try checkHasNode(newTail)
        try checkHasNode(newHead)
        var edge = try edge(edgeID)
        let oldTail = edge.tail
        let oldHead = edge.head
        guard oldTail != newTail || oldHead != newHead else {
            return self
        }
        edge.tail = newTail
        edge.head = newHead
        var copy = self
        copy._edges[edgeID] = edge

        if oldTail != newTail {
            try copy.withNode(newTail) { node in
                node.outEdges.insert(edgeID)
            }
            try copy.withNode(oldTail) { node in
                node.outEdges.remove(edgeID)
            }
        }
        if oldHead != newHead {
            try copy.withNode(newHead) { node in
                node.inEdges.insert(edgeID)
            }
            try copy.withNode(oldHead) { node in
                node.inEdges.remove(edgeID)
            }
        }
        return copy
    }
}

public extension Graph where NodeData: DefaultConstructable {
    func newNode(_ nodeID: NodeID) throws -> Self {
        try newNode(nodeID, NodeData())
    }
}

public extension Graph where NodeData == Void {
    func newNode(_ nodeID: NodeID) throws -> Self {
        try newNode(nodeID, ())
    }
}

public extension Graph where EdgeData: DefaultConstructable {
    func newEdge(_ edgeID: EdgeID, _ tailID: NodeID, _ headID: NodeID) throws -> Self {
        try newEdge(edgeID, tailID, headID, EdgeData())
    }
}

public extension Graph where EdgeData == Void {
    func newEdge(_ edgeID: EdgeID, _ tailID: NodeID, _ headID: NodeID) throws -> Self {
        try newEdge(edgeID, tailID, headID, ())
    }
}

private extension Graph {
    struct Node {
        var inEdges: Set<EdgeID> = []
        var outEdges: Set<EdgeID> = []
        var data: NodeData
        
        init(data: NodeData) {
            self.data = data
        }
    }
    
    struct Edge {
        var tail: NodeID
        var head: NodeID
        var data: EdgeData
    }
    
    enum Error: Swift.Error {
        case notFound
        case duplicate
    }
    
    func hasNode(_ nodeID: NodeID) -> Bool {
        _nodes[nodeID] != nil
    }
    
    func hasNoNode(_ nodeID: NodeID) -> Bool {
        !hasNode(nodeID)
    }
    
    func hasEdge(_ edgeID: EdgeID) -> Bool {
        _edges[edgeID] != nil
    }
    
    func hasNoEdge(_ edgeID: EdgeID) -> Bool {
        !hasEdge(edgeID)
    }
    
    func checkHasNode(_ nodeID: NodeID) throws {
        guard hasNode(nodeID) else {
            throw Error.notFound
        }
    }
    
    func checkHasNoNode(_ nodeID: NodeID) throws {
        guard hasNoNode(nodeID) else {
            throw Error.duplicate
        }
    }

    func checkHasEdge(_ edgeID: EdgeID) throws {
        guard hasEdge(edgeID) else {
            throw Error.notFound
        }
    }

    func checkHasNoEdge(_ edgeID: EdgeID) throws {
        guard hasNoEdge(edgeID) else {
            throw Error.duplicate
        }
    }

    func node(_ nodeID: NodeID) throws -> Node {
        guard let result = _nodes[nodeID] else {
            throw Error.notFound
        }
        return result
    }
    
    func edge(_ edgeID: EdgeID) throws -> Edge {
        guard let result = _edges[edgeID] else {
            throw Error.notFound
        }
        return result
    }
    
    mutating func withNode(_ nodeID: NodeID, transform: (inout Node) throws -> Void) throws {
        try transform(&_nodes[nodeID]!)
    }
    
    mutating func withEdge(_ edgeID: EdgeID, transform: (inout Edge) throws -> Void) throws {
        try transform(&_edges[edgeID]!)
    }
}

//extension Graph: Decodable where NodeID: Decodable, EdgeID: Decodable {
//    public init(from decoder: Decoder) throws {
//        let container = decoder.container(keyedBy: CodingKeys.self)
//    }
//}

extension Graph: Encodable where NodeID: Encodable, EdgeID: Encodable {
    enum CodingKeys: CodingKey {
        case nodes
        case edges
    }

    private struct EncodableGraph: Encodable {
        let nodes: Dictionary<NodeID, EncodableNode>
        let edges: Dictionary<EdgeID, EncodableEdge>
            
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            if NodeData.self is Encodable.Type {
                try container.encode(nodes, forKey: .nodes)
            } else {
                let connectedNodeIDs = edges.reduce(into: Set<NodeID>()) { result, element in
                    result.insert(element.value.edge.tail)
                    result.insert(element.value.edge.head)
                }
                let nodeIDs = Set(nodes.keys)
                let unconnectedNodeIDs = Array(nodeIDs.subtracting(connectedNodeIDs)).sorted()
                try container.encode(unconnectedNodeIDs, forKey: .nodes)
            }
            try container.encode(edges, forKey: .edges)
        }
        
        init(_ graph: Graph) {
            nodes = graph._nodes.reduce(into: .init()) { result, element in
                result[element.key] = EncodableNode(element.value)
            }
            
            edges = graph._edges.reduce(into: .init()) { result, element in
                result[element.key] = EncodableEdge(element.value)
            }
        }

        struct EncodableNode: Encodable {
            let node: Node
            
            init(_ node: Node) {
                self.node = node
            }
            
            func encode(to encoder: Encoder) throws {
                guard let data = node.data as? Encodable else {
                    return
                }
                var container = encoder.singleValueContainer()
                try container.encode(data)
            }
        }
        
        struct EncodableEdge: Encodable {
            let edge: Edge
            
            init(_ edge: Edge) {
                self.edge = edge
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()
                try container.encode(edge.tail)
                try container.encode(edge.head)
                if let data = edge.data as? Encodable {
                    try container.encode(data)
                }
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(EncodableGraph(self))
    }

    public var json: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return try! String(data: encoder.encode(self), encoding: .utf8)!
    }
}
