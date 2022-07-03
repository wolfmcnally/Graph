import Foundation

public protocol ViewableGraphWrapper: ViewableGraph where InnerGraph.NodeID == NodeID, InnerGraph.EdgeID == EdgeID, InnerGraph.NodeData == NodeData, InnerGraph.EdgeData == EdgeData {
    associatedtype InnerGraph: ViewableGraph
    
    var graph: InnerGraph { get }
}

public extension ViewableGraphWrapper {
    var isEmpty: Bool {
        graph.isEmpty
    }
    
    var nodesCount: Int {
        graph.nodesCount
    }
    
    var edgesCount: Int {
        graph.edgesCount
    }
    
    var nodes: [NodeID] {
        graph.nodes
    }
    
    var edges: [EdgeID] {
        graph.edges
    }
    
    func hasNode(_ node: NodeID) -> Bool {
        graph.hasNode(node)
    }
    
    func hasNoNode(_ node: NodeID) -> Bool {
        graph.hasNoNode(node)
    }
    
    func hasEdge(_ edge: EdgeID) -> Bool {
        graph.hasEdge(edge)
    }
    
    func hasNoEdge(_ edge: EdgeID) -> Bool {
        graph.hasNoEdge(edge)
    }
    
    func nodeData(_ node: NodeID) throws -> NodeData {
        try graph.nodeData(node)
    }
    
    func edgeData(_ edge: EdgeID) throws -> EdgeData {
        try graph.edgeData(edge)
    }
    
    func nodeOutEdges(_ node: NodeID) throws -> [EdgeID] {
        try graph.nodeOutEdges(node)
    }
    
    func nodeInEdges(_ node: NodeID) throws -> [EdgeID] {
        try graph.nodeInEdges(node)
    }
    
    func nodeEdges(_ node: NodeID) throws -> [EdgeID] {
        try graph.nodeEdges(node)
    }
    
    func nodeSuccessors(_ node: NodeID) throws -> [NodeID] {
        try graph.nodeSuccessors(node)
    }
    
    func nodePredecessors(_ node: NodeID) throws -> [NodeID] {
        try graph.nodePredecessors(node)
    }
    
    func nodeNeighbors(_ node: NodeID) throws -> [NodeID] {
        try graph.nodeNeighbors(node)
    }
    
    func edgeHead(_ edge: EdgeID) throws -> NodeID {
        try graph.edgeHead(edge)
    }
    
    func edgeTail(_ edge: EdgeID) throws -> NodeID {
        try graph.edgeTail(edge)
    }
    
    func edgeEnds(_ edge: EdgeID) throws -> (NodeID, NodeID) {
        try graph.edgeEnds(edge)
    }
}
