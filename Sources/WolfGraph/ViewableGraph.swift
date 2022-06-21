import Foundation

public protocol ViewableGraph {
    associatedtype NodeID: ElementID
    associatedtype EdgeID: ElementID
    associatedtype NodeData: ElementData
    associatedtype EdgeData: ElementData
    
    var isEmpty: Bool { get }

    var nodesCount: Int { get }
    var edgesCount: Int { get }

    var nodes: [NodeID] { get }
    var edges: [EdgeID] { get }

    func hasNode(_ nodeID: NodeID) -> Bool
    func hasNoNode(_ nodeID: NodeID) -> Bool
    func hasEdge(_ edgeID: EdgeID) -> Bool
    func hasNoEdge(_ edgeID: EdgeID) -> Bool

    func nodeData(_ nodeID: NodeID) throws -> NodeData
    func edgeData(_ edgeID: EdgeID) throws -> EdgeData

    func nodeOutEdges(_ nodeID: NodeID) throws -> [EdgeID]
    func nodeInEdges(_ nodeID: NodeID) throws -> [EdgeID]
    func nodeEdges(_ nodeID: NodeID) throws -> [EdgeID]

    func nodeSuccessors(_ nodeID: NodeID) throws -> [NodeID]
    func nodePredecessors(_ nodeID: NodeID) throws -> [NodeID]
    func nodeNeighbors(_ nodeID: NodeID) throws -> [NodeID]

    func edgeHead(_ edgeID: EdgeID) throws -> NodeID
    func edgeTail(_ edgeID: EdgeID) throws -> NodeID
}
