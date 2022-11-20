import Foundation
import SortedCollections

public protocol ViewableGraph  {
    associatedtype NodeID: ElementID
    associatedtype EdgeID: ElementID
    associatedtype NodeData
    associatedtype EdgeData
    associatedtype GraphData
    
    var isEmpty: Bool { get }

    var nodesCount: Int { get }
    var edgesCount: Int { get }

    var nodes: SortedSet<NodeID> { get }
    var edges: SortedSet<EdgeID> { get }

    func hasNode(_ node: NodeID) -> Bool
    func hasNoNode(_ node: NodeID) -> Bool
    func hasEdge(_ edge: EdgeID) -> Bool
    func hasNoEdge(_ edge: EdgeID) -> Bool

    func nodeData(_ node: NodeID) throws -> NodeData
    func edgeData(_ edge: EdgeID) throws -> EdgeData
    var data: GraphData { get }

    func nodeOutEdges(_ node: NodeID) throws -> SortedSet<EdgeID>
    func nodeInEdges(_ node: NodeID) throws -> SortedSet<EdgeID>
    func nodeEdges(_ node: NodeID) throws -> SortedSet<EdgeID>

    func nodeSuccessors(_ node: NodeID) throws -> SortedSet<NodeID>
    func nodePredecessors(_ node: NodeID) throws -> SortedSet<NodeID>
    func nodeNeighbors(_ node: NodeID) throws -> SortedSet<NodeID>

    func hasSuccessors(_ node: NodeID) throws -> Bool
    func hasPredecessors(_ node: NodeID) throws -> Bool
    func hasNeighbors(_ node: NodeID) throws -> Bool

    func edgeHead(_ edge: EdgeID) throws -> NodeID
    func edgeTail(_ edge: EdgeID) throws -> NodeID
    func edgeEnds(_ edge: EdgeID) throws -> (NodeID, NodeID)
}

public extension ViewableGraph where GraphData == Empty {
    var data: Empty {
        Empty()
    }
}

public extension ViewableGraph where GraphData == Void {
    var data: Void {
        ()
    }
}
