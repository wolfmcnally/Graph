import Foundation

public struct Graph<NodeID, EdgeID, NodeData, EdgeData>: Equatable
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
    
    public func hasNode(_ nodeID: NodeID) -> Bool {
        _nodes[nodeID] != nil
    }
    
    public func hasNoNode(_ nodeID: NodeID) -> Bool {
        !hasNode(nodeID)
    }
    
    public func hasEdge(_ edgeID: EdgeID) -> Bool {
        _edges[edgeID] != nil
    }
    
    public func hasNoEdge(_ edgeID: EdgeID) -> Bool {
        !hasEdge(edgeID)
    }

    public func nodeData(_ nodeID: NodeID) throws -> NodeData {
        try node(nodeID).data
    }
    
    public func edgeData(_ edgeID: EdgeID) throws -> EdgeData {
        try edge(edgeID).data
    }

    public func nodeOutEdges(_ nodeID: NodeID) throws -> [EdgeID] {
        try node(nodeID).outEdges.sorted()
    }
    
    public func nodeInEdges(_ nodeID: NodeID) throws -> [EdgeID] {
        try node(nodeID).inEdges.sorted()
    }
    
    public func nodeEdges(_ nodeID: NodeID) throws -> [EdgeID] {
        try Array(Set(nodeOutEdges(nodeID)).union(Set(nodeInEdges(nodeID)))).sorted()
    }
    
    public func nodeSuccessors(_ nodeID: NodeID) throws -> [NodeID] {
        try nodeOutEdges(nodeID).map(edgeHead).sorted()
    }
    
    public func nodePredecessors(_ nodeID: NodeID) throws -> [NodeID] {
        try nodeInEdges(nodeID).map(edgeTail).sorted()
    }
    
    public func nodeNeighbors(_ nodeID: NodeID) throws -> [NodeID] {
        let successors = try nodeSuccessors(nodeID)
        let predececessors = try nodePredecessors(nodeID)
        return Array(Set(successors).union(Set(predececessors))).sorted()
    }
    
    public func edgeHead(_ edgeID: EdgeID) throws -> NodeID {
        try edge(edgeID).head
    }

    public func edgeTail(_ edgeID: EdgeID) throws -> NodeID {
        try edge(edgeID).tail
    }
}

extension Graph: EditableGraph {
    public func withNodeData(_ nodeID: NodeID, transform: (inout NodeData) -> Void) throws -> Self {
        try checkHasNode(nodeID)
        var copy = self
        transform(&copy._nodes[nodeID]!.data)
        return copy
    }

    public func setNodeData(_ nodeID: NodeID, data: NodeData) throws -> Self {
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

    public func setEdgeData(_ edgeID: EdgeID, data: EdgeData) throws -> Self {
        try withEdgeData(edgeID) {
            $0 = data
        }
    }

    public func newNode(_ nodeID: NodeID, data: NodeData) throws -> Self {
        try checkHasNoNode(nodeID)
        var copy = self
        copy._nodes[nodeID] = Node(data: data)
        return copy
    }

    public func newNode(_ nodeID: NodeID) throws -> Self {
        try newNode(nodeID, data: NodeData())
    }

    public func removeNode(_ nodeID: NodeID) throws -> Self {
        var copy = try removeNodeEdges(nodeID)
        copy._nodes.removeValue(forKey: nodeID)
        return copy
    }

    public func newEdge(_ edgeID: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws -> Self {
        try checkHasNoEdge(edgeID)
        try checkHasNode(tail)
        try checkHasNode(head)
        
        var copy = self
        copy._edges[edgeID] = Edge(tail: tail, head: head, data: data)
        copy._nodes[tail]!.outEdges.insert(edgeID)
        copy._nodes[head]!.inEdges.insert(edgeID)
        return copy
    }

    public func newEdge(_ edgeID: EdgeID, tail: NodeID, head: NodeID) throws -> Self {
        try newEdge(edgeID, tail: tail, head: head, data: EdgeData())
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

private extension Graph {
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
