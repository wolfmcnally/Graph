import Foundation
import SortedCollections
import OrderedCollections

public protocol ViewableGraphWrapper2: ViewableGraph2
where InnerGraph.NodeID == NodeID, InnerGraph.EdgeID == EdgeID,
      InnerGraph.NodeData == NodeData, InnerGraph.EdgeData == EdgeData
{
    associatedtype InnerGraph: ViewableGraph2
    
    var graph: InnerGraph { get }
}

public extension ViewableGraphWrapper2 {
    var isEmpty: Bool { graph.isEmpty }
    var nodesCount: Int { graph.nodesCount }
    var edgesCount: Int { graph.edgesCount }
    var nodes: SortedSet<NodeID> { graph.nodes }
    var edges: SortedSet<EdgeID> { graph.edges }
    func hasNode(_ node: NodeID) -> Bool { graph.hasNode(node) }
    func hasNoNode(_ node: NodeID) -> Bool { graph.hasNoNode(node) }
    func hasEdge(_ edge: EdgeID) -> Bool { graph.hasEdge(edge) }
    func hasNoEdge(_ edge: EdgeID) -> Bool { graph.hasNoEdge(edge) }
    func nodeData(_ node: NodeID) throws -> NodeData { try graph.nodeData(node) }
    func edgeData(_ edge: EdgeID) throws -> EdgeData { try graph.edgeData(edge) }
    func nodeInEdges(_ node: NodeID) throws -> SortedSet<EdgeID> { try graph.nodeInEdges(node) }
    func nodeEdges(_ node: NodeID) throws -> SortedSet<EdgeID> { try graph.nodeEdges(node) }
    func nodePredecessors(_ node: NodeID) throws -> SortedSet<NodeID> { try graph.nodePredecessors(node) }
    func nodeNeighbors(_ node: NodeID) throws -> SortedSet<NodeID> { try graph.nodeNeighbors(node) }
    func hasSuccessors(_ node: NodeID) throws -> Bool { try graph.hasSuccessors(node) }
    func hasPredecessors(_ node: NodeID) throws -> Bool { try graph.hasPredecessors(node) }
    func hasNeighbors(_ node: NodeID) throws -> Bool { try graph.hasNeighbors(node) }
    func edgeHead(_ edge: EdgeID) throws -> NodeID { try graph.edgeHead(edge) }
    func edgeTail(_ edge: EdgeID) throws -> NodeID { try graph.edgeTail(edge) }
    func edgeEnds(_ edge: EdgeID) throws -> (NodeID, NodeID) { try graph.edgeEnds(edge) }
}

public protocol ViewableGraphWrapper: ViewableGraphWrapper2 where InnerGraph: ViewableGraph {
    func nodeOutEdges(_ node: NodeID) throws -> SortedSet<EdgeID>
    func nodeSuccessors(_ node: NodeID) throws -> SortedSet<NodeID>
}

public extension ViewableGraphWrapper {
    func nodeOutEdges(_ node: NodeID) throws -> SortedSet<EdgeID> { try graph.nodeOutEdges(node) }
    func nodeSuccessors(_ node: NodeID) throws -> SortedSet<NodeID> { try graph.nodeSuccessors(node) }
}

public protocol OrderedViewableGraphWrapper: ViewableGraphWrapper2 where InnerGraph: OrderedViewableGraph {
    func nodeOutEdges(_ node: NodeID) throws -> OrderedSet<EdgeID>
    func nodeSuccessors(_ node: NodeID) throws -> OrderedSet<NodeID>
}

public extension OrderedViewableGraphWrapper {
    func nodeOutEdges(_ node: NodeID) throws -> OrderedSet<EdgeID> { try graph.nodeOutEdges(node) }
    func nodeSuccessors(_ node: NodeID) throws -> OrderedSet<NodeID> { try graph.nodeSuccessors(node) }
}
