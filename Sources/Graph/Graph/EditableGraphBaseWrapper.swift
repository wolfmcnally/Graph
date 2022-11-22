import Foundation

public protocol EditableGraphBaseWrapper2: EditableGraphBase2, ViewableGraphWrapper2
where InnerGraph: EditableGraphBase2
{
    var graph: InnerGraph { get set }
}

public extension EditableGraphBaseWrapper2 {
    mutating func withNodeData<T>(_ node: NodeID, transform: (inout NodeData) throws -> T) throws -> T {
        try graph.withNodeData(node, transform: transform)
    }

    mutating func withEdgeData<T>(_ edge: EdgeID, transform: (inout EdgeData) throws -> T) throws -> T {
        try graph.withEdgeData(edge, transform: transform)
    }

    mutating func removeNode(_ node: NodeID) throws {
        try graph.removeNode(node)
    }

    mutating func removeEdge(_ edge: EdgeID) throws {
        try graph.removeEdge(edge)
    }

    mutating func removeNodeEdges(_ node: NodeID) throws {
        try graph.removeNodeEdges(node)
    }

    mutating func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws {
        try graph.newEdge(edge, tail: tail, head: head, data: data)
    }

    mutating func moveEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws {
        try graph.moveEdge(edge, newTail: newTail, newHead: newHead)
    }
}

public protocol EditableGraphBaseWrapper: EditableGraphBaseWrapper2, EditableGraphBase, ViewableGraphWrapper
where InnerGraph: EditableGraphBase
{
}

public protocol OrderedEditableGraphBaseWrapper: EditableGraphBaseWrapper2, OrderedEditableGraphBase, OrderedViewableGraphWrapper
where InnerGraph: OrderedEditableGraphBase
{
}

public extension OrderedEditableGraphBaseWrapper {
    mutating func newEdge(_ edge: EdgeID, tail: NodeID, at index: Int, head: NodeID, data: EdgeData) throws {
        try graph.newEdge(edge, tail: tail, at: index, head: head, data: data)
    }

    mutating func moveEdge(_ edge: EdgeID, newTail: NodeID, at index: Int, newHead: NodeID) throws {
        try graph.moveEdge(edge, newTail: newTail, at: index, newHead: newHead)
    }
}
