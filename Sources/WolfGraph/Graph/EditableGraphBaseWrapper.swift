import Foundation

public protocol EditableGraphBaseWrapper: EditableGraphBase
where InnerGraph: EditableGraphBase,
      NodeID == InnerGraph.NodeID, EdgeID == InnerGraph.EdgeID,
      NodeData == InnerGraph.NodeData, EdgeData == InnerGraph.EdgeData
{
    associatedtype InnerGraph
    
    var graph: InnerGraph { get set }
}

public extension EditableGraphBaseWrapper {
    mutating func withNodeData(_ node: NodeID, transform: (inout NodeData) -> Void) throws {
        try graph.withNodeData(node, transform: transform)
    }

    mutating func withEdgeData(_ edge: EdgeID, transform: (inout EdgeData) -> Void) throws {
        try graph.withEdgeData(edge, transform: transform)
    }

    mutating func removeNode(_ node: NodeID) throws {
        try graph.removeNode(node)
    }

    mutating func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws {
        try graph.newEdge(edge, tail: tail, head: head, data: data)
    }

    mutating func removeEdge(_ edge: EdgeID) throws {
        try graph.removeEdge(edge)
    }

    mutating func removeNodeEdges(_ node: NodeID) throws {
        try graph.removeNodeEdges(node)
    }
    
    mutating func moveEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws {
        try graph.moveEdge(edge, newTail: newTail, newHead: newHead)
    }
}
