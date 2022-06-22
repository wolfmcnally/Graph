import Foundation

public protocol ViewableGraph where InnerGraph.NodeID == NodeID, InnerGraph.EdgeID == EdgeID, InnerGraph.NodeData == NodeData, InnerGraph.EdgeData == EdgeData {
    associatedtype NodeID: ElementID
    associatedtype EdgeID: ElementID
    associatedtype NodeData: ElementData
    associatedtype EdgeData: ElementData

    associatedtype InnerGraph: ViewableGraph
    
    var innerGraph: InnerGraph { get }
    
    var isEmpty: Bool { get }

    var nodesCount: Int { get }
    var edgesCount: Int { get }

    var nodes: [NodeID] { get }
    var edges: [EdgeID] { get }

    func hasNode(_ node: NodeID) -> Bool
    func hasNoNode(_ node: NodeID) -> Bool
    func hasEdge(_ edge: EdgeID) -> Bool
    func hasNoEdge(_ edge: EdgeID) -> Bool

    func nodeData(_ node: NodeID) throws -> NodeData
    func edgeData(_ edge: EdgeID) throws -> EdgeData

    func nodeOutEdges(_ node: NodeID) throws -> [EdgeID]
    func nodeInEdges(_ node: NodeID) throws -> [EdgeID]
    func nodeEdges(_ node: NodeID) throws -> [EdgeID]

    func nodeSuccessors(_ node: NodeID) throws -> [NodeID]
    func nodePredecessors(_ node: NodeID) throws -> [NodeID]
    func nodeNeighbors(_ node: NodeID) throws -> [NodeID]

    func edgeHead(_ edge: EdgeID) throws -> NodeID
    func edgeTail(_ edge: EdgeID) throws -> NodeID
}

public extension ViewableGraph {
    var innerGraph: Self {
        self
    }

    var isEmpty: Bool {
        innerGraph.isEmpty
    }
    
    var nodesCount: Int {
        innerGraph.nodesCount
    }
    
    var edgesCount: Int {
        innerGraph.edgesCount
    }
    
    var nodes: [NodeID] {
        innerGraph.nodes
    }
    
    var edges: [EdgeID] {
        innerGraph.edges
    }
    
    func hasNode(_ node: NodeID) -> Bool {
        innerGraph.hasNode(node)
    }
    
    func hasNoNode(_ node: NodeID) -> Bool {
        innerGraph.hasNoNode(node)
    }
    
    func hasEdge(_ edge: EdgeID) -> Bool {
        innerGraph.hasEdge(edge)
    }
    
    func hasNoEdge(_ edge: EdgeID) -> Bool {
        innerGraph.hasNoEdge(edge)
    }
    
    func nodeData(_ node: NodeID) throws -> NodeData {
        try innerGraph.nodeData(node)
    }
    
    func edgeData(_ edge: EdgeID) throws -> EdgeData {
        try innerGraph.edgeData(edge)
    }
    
    func nodeOutEdges(_ node: NodeID) throws -> [EdgeID] {
        try innerGraph.nodeOutEdges(node)
    }
    
    func nodeInEdges(_ node: NodeID) throws -> [EdgeID] {
        try innerGraph.nodeInEdges(node)
    }
    
    func nodeEdges(_ node: NodeID) throws -> [EdgeID] {
        try innerGraph.nodeEdges(node)
    }
    
    func nodeSuccessors(_ node: NodeID) throws -> [NodeID] {
        try innerGraph.nodeSuccessors(node)
    }
    
    func nodePredecessors(_ node: NodeID) throws -> [NodeID] {
        try innerGraph.nodePredecessors(node)
    }
    
    func nodeNeighbors(_ node: NodeID) throws -> [NodeID] {
        try innerGraph.nodeNeighbors(node)
    }
    
    func edgeHead(_ edge: EdgeID) throws -> NodeID {
        try innerGraph.edgeHead(edge)
    }
    
    func edgeTail(_ edge: EdgeID) throws -> NodeID {
        try innerGraph.edgeTail(edge)
    }
}
