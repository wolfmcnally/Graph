import Foundation

public protocol EditableGraphBase2: ViewableGraph2 {
    var data: GraphData { get set }
    
    mutating func withNodeData<T>(_ node: NodeID, transform: (inout NodeData) throws -> T) throws -> T
    mutating func setNodeData(_ node: NodeID, data: NodeData) throws
    mutating func withEdgeData<T>(_ edge: EdgeID, transform: (inout EdgeData) throws -> T) throws -> T
    mutating func setEdgeData(_ edge: EdgeID, data: EdgeData) throws
    
    mutating func removeNode(_ node: NodeID) throws
    mutating func removeEdge(_ edge: EdgeID) throws
    mutating func removeNodeEdges(_ node: NodeID) throws

    mutating func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws
    mutating func moveEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws
}

extension EditableGraphBase2 {
    public mutating func setNodeData(_ node: NodeID, data: NodeData) throws {
        try withNodeData(node) {
            $0 = data
        }
    }

    public mutating func setEdgeData(_ edge: EdgeID, data: EdgeData) throws {
        try withEdgeData(edge) {
            $0 = data
        }
    }
}

public extension EditableGraphBase2 where EdgeData: DefaultConstructable {
    mutating func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID) throws {
        try newEdge(edge, tail: tail, head: head, data: EdgeData())
    }
}

public extension EditableGraphBase2 where EdgeData == Void {
    mutating func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID) throws {
        try newEdge(edge, tail: tail, head: head, data: ())
    }
}

public extension EditableGraphBase2 where GraphData == Empty {
    var data: Empty {
        get { Empty() }
        set { }
    }
}

public extension EditableGraphBase2 where GraphData == Void {
    var data: Void {
        get { () }
        set { }
    }
}

public protocol EditableGraphBase: EditableGraphBase2, ViewableGraph {
}

public protocol OrderedEditableGraphBase: EditableGraphBase2, OrderedViewableGraph {
    mutating func newEdge(_ edge: EdgeID, tail: NodeID, at index: Int, head: NodeID, data: EdgeData) throws
    mutating func moveEdge(_ edge: EdgeID, newTail: NodeID, at index: Int, newHead: NodeID) throws
}

public extension OrderedEditableGraphBase where EdgeData: DefaultConstructable {
    mutating func newEdge(_ edge: EdgeID, tail: NodeID, at index: Int, head: NodeID) throws {
        try newEdge(edge, tail: tail, at: index, head: head, data: EdgeData())
    }
}

public extension OrderedEditableGraphBase where EdgeData == Void {
    mutating func newEdge(_ edge: EdgeID, tail: NodeID, at index: Int, head: NodeID) throws {
        try newEdge(edge, tail: tail, at: index, head: head, data: ())
    }
}
