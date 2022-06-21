import Foundation

public struct Graph<NodeID, EdgeID, NodeData, EdgeData>: Equatable, JSONCodable
where NodeID: ElementID, EdgeID: ElementID, NodeData: ElementData, EdgeData: ElementData
{
    struct Node: Equatable {
        var inEdges: Set<EdgeID> = []
        var outEdges: Set<EdgeID> = []
        var data: NodeData
        
        init(data: NodeData) {
            self.data = data
        }
    }
    
    struct Edge: Equatable {
        var tail: NodeID
        var head: NodeID
        var data: EdgeData
    }
    
    enum Error: Swift.Error {
        case notFound
        case duplicate
    }
    
    var _nodes: [NodeID: Node] = [:]
    var _edges: [EdgeID: Edge] = [:]
    
    public init() { }
}

extension Graph: ViewableGraph {
    public var isEmpty: Bool {
        nodesCount == 0
    }

    public var nodesCount: Int {
        _nodes.count
    }
    
    public var edgesCount: Int {
        _edges.count
    }

    public var nodes: [NodeID] {
        Array(_nodes.keys).sorted()
    }
    
    public var edges: [EdgeID] {
        Array(_edges.keys).sorted()
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

    public func nodeOutEdges(_ node: NodeID) throws -> [EdgeID] {
        try getNode(node).outEdges.sorted()
    }
    
    public func nodeInEdges(_ node: NodeID) throws -> [EdgeID] {
        try getNode(node).inEdges.sorted()
    }
    
    public func nodeEdges(_ node: NodeID) throws -> [EdgeID] {
        try Array(Set(nodeOutEdges(node)).union(Set(nodeInEdges(node)))).sorted()
    }
    
    public func nodeSuccessors(_ node: NodeID) throws -> [NodeID] {
        try nodeOutEdges(node).map(edgeHead).sorted()
    }
    
    public func nodePredecessors(_ node: NodeID) throws -> [NodeID] {
        try nodeInEdges(node).map(edgeTail).sorted()
    }
    
    public func nodeNeighbors(_ node: NodeID) throws -> [NodeID] {
        let successors = try nodeSuccessors(node)
        let predececessors = try nodePredecessors(node)
        return Array(Set(successors).union(Set(predececessors))).sorted()
    }
    
    public func edgeHead(_ edge: EdgeID) throws -> NodeID {
        try getEdge(edge).head
    }

    public func edgeTail(_ edge: EdgeID) throws -> NodeID {
        try getEdge(edge).tail
    }
}

extension Graph: EditableGraph {
    public func withNodeData(_ node: NodeID, transform: (inout NodeData) -> Void) throws -> Self {
        try checkHasNode(node)
        var copy = self
        transform(&copy._nodes[node]!.data)
        return copy
    }

    public func withEdgeData(_ edge: EdgeID, transform: (inout EdgeData) -> Void) throws -> Self {
        try checkHasEdge(edge)
        var copy = self
        transform(&copy._edges[edge]!.data)
        return copy
    }

    public func setEdgeData(_ edge: EdgeID, data: EdgeData) throws -> Self {
        try withEdgeData(edge) {
            $0 = data
        }
    }

    public func newNode(_ node: NodeID, data: NodeData) throws -> Self {
        try checkHasNoNode(node)
        var copy = self
        copy._nodes[node] = Node(data: data)
        return copy
    }

    public func removeNode(_ node: NodeID) throws -> Self {
        var copy = try removeNodeEdges(node)
        copy._nodes.removeValue(forKey: node)
        return copy
    }

    public func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws -> Self {
        try checkHasNoEdge(edge)
        try checkHasNode(tail)
        try checkHasNode(head)
        
        var copy = self
        copy._edges[edge] = Edge(tail: tail, head: head, data: data)
        copy._nodes[tail]!.outEdges.insert(edge)
        copy._nodes[head]!.inEdges.insert(edge)
        return copy
    }

    public func removeEdge(_ edge: EdgeID) throws -> Self {
        let e = try getEdge(edge)
        var copy = self
        copy._nodes[e.tail]!.outEdges.remove(edge)
        copy._nodes[e.head]!.inEdges.remove(edge)
        copy._edges.removeValue(forKey: edge)
        return copy
    }

    public func removeNodeEdges(_ node: NodeID) throws -> Self {
        var copy = self
        try nodeEdges(node).forEach {
            copy = try! copy.removeEdge($0)
        }
        return copy
    }
    
    public func moveEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws -> Self {
        try checkHasNode(newTail)
        try checkHasNode(newHead)
        var e = try getEdge(edge)
        let oldTail = e.tail
        let oldHead = e.head
        guard oldTail != newTail || oldHead != newHead else {
            return self
        }
        e.tail = newTail
        e.head = newHead
        var copy = self
        copy._edges[edge] = e

        if oldTail != newTail {
            try copy.withNode(newTail) { node in
                node.outEdges.insert(edge)
            }
            try copy.withNode(oldTail) { node in
                node.outEdges.remove(edge)
            }
        }
        if oldHead != newHead {
            try copy.withNode(newHead) { node in
                node.inEdges.insert(edge)
            }
            try copy.withNode(oldHead) { node in
                node.inEdges.remove(edge)
            }
        }
        return copy
    }
}

private extension Graph {
    func checkHasNode(_ node: NodeID) throws {
        guard hasNode(node) else {
            throw Error.notFound
        }
    }
    
    func checkHasNoNode(_ node: NodeID) throws {
        guard hasNoNode(node) else {
            throw Error.duplicate
        }
    }

    func checkHasEdge(_ edge: EdgeID) throws {
        guard hasEdge(edge) else {
            throw Error.notFound
        }
    }

    func checkHasNoEdge(_ edge: EdgeID) throws {
        guard hasNoEdge(edge) else {
            throw Error.duplicate
        }
    }

    func getNode(_ node: NodeID) throws -> Node {
        guard let result = _nodes[node] else {
            throw Error.notFound
        }
        return result
    }
    
    func getEdge(_ edge: EdgeID) throws -> Edge {
        guard let result = _edges[edge] else {
            throw Error.notFound
        }
        return result
    }
    
    mutating func withNode(_ node: NodeID, transform: (inout Node) throws -> Void) throws {
        try transform(&_nodes[node]!)
    }
    
    mutating func withEdge(_ edge: EdgeID, transform: (inout Edge) throws -> Void) throws {
        try transform(&_edges[edge]!)
    }
}
