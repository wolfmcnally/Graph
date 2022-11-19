import Foundation
import SortedCollections

public struct Graph<NodeID, EdgeID, NodeData, EdgeData, GraphData>: EditableGraph
where NodeID: ElementID, EdgeID: ElementID
{
    // These should be replaced with SortedDictionary from Swift Collections when it's ready
    var _nodes: SortedDictionary<NodeID, Node> = [:]
    var _edges: SortedDictionary<EdgeID, Edge> = [:]
    public var data: GraphData
    
    public init(data: GraphData) {
        self.data = data
    }

    struct Node {
        // These should be replaced with SortedSet from Swift Collections when it's ready
        var inEdges: SortedSet<EdgeID> = []
        var outEdges: SortedSet<EdgeID> = []
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
}

extension Graph where GraphData == Void {
    public init() {
        self.init(data: ())
    }
}

extension Graph where GraphData: DefaultConstructable {
    public init() {
        self.init(data: GraphData())
    }
}

// MARK: - ViewableGraph Implementations

extension Graph {
    public var isEmpty: Bool {
        nodesCount == 0
    }

    public var nodesCount: Int {
        _nodes.count
    }
    
    public var edgesCount: Int {
        _edges.count
    }

    public var nodes: SortedSet<NodeID> {
        SortedSet(_nodes.keys)
    }
    
    public var edges: SortedSet<EdgeID> {
        SortedSet(_edges.keys)
    }
    
    public func hasNode(_ node: NodeID) -> Bool {
        _nodes[node] != nil
    }
    
    public func hasNoNode(_ node: NodeID) -> Bool {
        !hasNode(node)
    }
    
    public func hasEdge(_ edge: EdgeID) -> Bool {
        _edges[edge] != nil
    }
    
    public func hasNoEdge(_ edge: EdgeID) -> Bool {
        !hasEdge(edge)
    }

    public func nodeData(_ node: NodeID) throws -> NodeData {
        try getNode(node).data
    }
    
    public func edgeData(_ edge: EdgeID) throws -> EdgeData {
        try getEdge(edge).data
    }

    public func nodeOutEdges(_ node: NodeID) throws -> SortedSet<EdgeID> {
        try getNode(node).outEdges
    }
    
    public func nodeInEdges(_ node: NodeID) throws -> SortedSet<EdgeID> {
        try getNode(node).inEdges
    }
    
    public func nodeEdges(_ node: NodeID) throws -> SortedSet<EdgeID> {
        try nodeOutEdges(node).union(nodeInEdges(node))
    }
    
    public func nodeSuccessors(_ node: NodeID) throws -> SortedSet<NodeID> {
        try SortedSet(nodeOutEdges(node).map(edgeHead))
    }
    
    public func nodePredecessors(_ node: NodeID) throws -> SortedSet<NodeID> {
        try SortedSet(nodeInEdges(node).map(edgeTail))
    }
    
    public func nodeNeighbors(_ node: NodeID) throws -> SortedSet<NodeID> {
        let successors = try nodeSuccessors(node)
        let predececessors = try nodePredecessors(node)
        return successors.union(predececessors)
    }
    
    public func edgeHead(_ edge: EdgeID) throws -> NodeID {
        try getEdge(edge).head
    }

    public func edgeTail(_ edge: EdgeID) throws -> NodeID {
        try getEdge(edge).tail
    }
    
    public func edgeEnds(_ edge: EdgeID) throws -> (NodeID, NodeID) {
        let e = try getEdge(edge)
        return (e.tail, e.head)
    }
}

// MARK: - EditableGraph Implementations

extension Graph {
    @discardableResult
    public mutating func withNodeData<T>(_ node: NodeID, transform: (inout NodeData) throws -> T) throws -> T {
        try checkHasNode(node)
        return try transform(&_nodes[node]!.data)
    }

    @discardableResult
    public mutating func withEdgeData<T>(_ edge: EdgeID, transform: (inout EdgeData) throws -> T) throws -> T {
        try checkHasEdge(edge)
        return try transform(&_edges[edge]!.data)
    }

    public mutating func setEdgeData(_ edge: EdgeID, data: EdgeData) throws {
        try withEdgeData(edge) {
            $0 = data
        }
    }
    
    public mutating func newNode(_ node: NodeID, data: NodeData) throws {
        try checkHasNoNode(node)
        _nodes[node] = Node(data: data)
    }

    public mutating func removeNode(_ node: NodeID) throws {
        try removeNodeEdges(node)
        _nodes.removeValue(forKey: node)
    }

    public mutating func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws {
        try checkHasNoEdge(edge)
        try checkHasNode(tail)
        try checkHasNode(head)
        
        _edges[edge] = Edge(tail: tail, head: head, data: data)
        _nodes[tail]!.outEdges.insert(edge)
        _nodes[head]!.inEdges.insert(edge)
    }

    public mutating func removeEdge(_ edge: EdgeID) throws {
        let e = try getEdge(edge)
        _nodes[e.tail]!.outEdges.remove(edge)
        _nodes[e.head]!.inEdges.remove(edge)
        _edges.removeValue(forKey: edge)
    }

    public mutating func removeNodeEdges(_ node: NodeID) throws {
        let edges = try nodeEdges(node)
        edges.forEach {
            try! removeEdge($0)
        }
    }
    
    public mutating func moveEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws {
        try checkHasNode(newTail)
        try checkHasNode(newHead)
        var e = try getEdge(edge)
        let oldTail = e.tail
        let oldHead = e.head
        guard oldTail != newTail || oldHead != newHead else {
            return
        }
        e.tail = newTail
        e.head = newHead
        _edges[edge] = e

        if oldTail != newTail {
            try withNode(newTail) { node in
                node.outEdges.insert(edge)
            }
            try withNode(oldTail) { node in
                node.outEdges.remove(edge)
            }
        }
        if oldHead != newHead {
            try withNode(newHead) { node in
                node.inEdges.insert(edge)
            }
            try withNode(oldHead) { node in
                node.inEdges.remove(edge)
            }
        }
    }
}

public extension Graph where NodeData: DefaultConstructable {
    mutating func newNode(_ node: NodeID) throws {
        try newNode(node, data: NodeData())
    }
}

public extension Graph where NodeData == Void {
    mutating func newNode(_ node: NodeID) throws {
        try newNode(node, data: ())
    }
}

private extension Graph {
    func checkHasNode(_ node: NodeID) throws {
        guard hasNode(node) else {
            throw GraphError.notFound
        }
    }
    
    func checkHasNoNode(_ node: NodeID) throws {
        guard hasNoNode(node) else {
            throw GraphError.duplicate
        }
    }

    func checkHasEdge(_ edge: EdgeID) throws {
        guard hasEdge(edge) else {
            throw GraphError.notFound
        }
    }

    func checkHasNoEdge(_ edge: EdgeID) throws {
        guard hasNoEdge(edge) else {
            throw GraphError.duplicate
        }
    }

    func getNode(_ node: NodeID) throws -> Node {
        guard let result = _nodes[node] else {
            throw GraphError.notFound
        }
        return result
    }
    
    func getEdge(_ edge: EdgeID) throws -> Edge {
        guard let result = _edges[edge] else {
            throw GraphError.notFound
        }
        return result
    }
    
    @discardableResult
    mutating func withNode<T>(_ node: NodeID, transform: (inout Node) throws -> T) throws -> T {
        try transform(&_nodes[node]!)
    }
    
    @discardableResult
    mutating func withEdge<T>(_ edge: EdgeID, transform: (inout Edge) throws -> T) throws -> T {
        try transform(&_edges[edge]!)
    }
}

extension Graph.Node: Equatable where Graph.NodeData: Equatable {
    static func == (lhs: Graph.Node, rhs: Graph.Node) -> Bool {
        lhs.inEdges == rhs.inEdges && lhs.outEdges == rhs.outEdges && lhs.data == rhs.data
    }
}

extension Graph.Edge: Equatable where Graph.EdgeData: Equatable {
    static func == (lhs: Graph.Edge, rhs: Graph.Edge) -> Bool {
        lhs.tail == rhs.tail && lhs.head == rhs.head && lhs.data == rhs.data
    }
}

extension Graph: Equatable where Graph.NodeData: Equatable, Graph.EdgeData: Equatable {
    public static func == (lhs: Graph, rhs: Graph) -> Bool {
        lhs._nodes == rhs._nodes && lhs._edges == rhs._edges
    }
}
