import Foundation

public protocol EditableGraph: ViewableGraph {
    func withNodeData(_ nodeID: NodeID, transform: (inout NodeData) -> Void) throws -> Self
    func setNodeData(_ nodeID: NodeID, data: NodeData) throws -> Self
    func withEdgeData(_ edgeID: EdgeID, transform: (inout EdgeData) -> Void) throws -> Self
    func setEdgeData(_ edgeID: EdgeID, data: EdgeData) throws -> Self
    func newNode(_ nodeID: NodeID, data: NodeData) throws -> Self
    func newNode(_ nodeID: NodeID) throws -> Self
    func removeNode(_ nodeID: NodeID) throws -> Self
    func newEdge(_ edgeID: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws -> Self
    func newEdge(_ edgeID: EdgeID, tail: NodeID, head: NodeID) throws -> Self
    func removeEdge(_ edgeID: EdgeID) throws -> Self
    func removeNodeEdges(_ nodeID: NodeID) throws -> Self
    func moveEdge(_ edgeID: EdgeID, newTail: NodeID, newHead: NodeID) throws -> Self
}
