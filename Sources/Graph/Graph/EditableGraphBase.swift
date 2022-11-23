import Foundation

public protocol EditableGraphBase: ViewableGraph {
    mutating func withNodeData<T>(_ node: NodeID, transform: (inout NodeData) throws -> T) throws -> T
    mutating func setNodeData(_ node: NodeID, data: NodeData) throws
    mutating func withEdgeData<T>(_ edge: EdgeID, transform: (inout EdgeData) throws -> T) throws -> T
    mutating func setEdgeData(_ edge: EdgeID, data: EdgeData) throws
    
    mutating func removeNode(_ node: NodeID) throws
    mutating func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws
    mutating func newEdge(_ edge: EdgeID, tail: NodeID, at index: Int, head: NodeID, data: EdgeData) throws
    mutating func removeEdge(_ edge: EdgeID) throws
    mutating func removeNodeEdges(_ node: NodeID) throws
    mutating func moveEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws
    mutating func moveEdge(_ edge: EdgeID, newTail: NodeID, at index: Int, newHead: NodeID) throws
    mutating func moveEdge(_ edge: EdgeID, to index: Int) throws
    mutating func moveEdgeToFront(_ edge: EdgeID) throws
    mutating func moveEdgeToBack(_ edge: EdgeID) throws
    var data: GraphData { get set }
}

extension EditableGraphBase {
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

public extension EditableGraphBase where EdgeData: DefaultConstructable {
    mutating func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID) throws {
        try newEdge(edge, tail: tail, head: head, data: EdgeData())
    }

    mutating func newEdge(_ edge: EdgeID, tail: NodeID, at index: Int, head: NodeID) throws {
        try newEdge(edge, tail: tail, at: index, head: head, data: EdgeData())
    }
}

public extension EditableGraphBase where EdgeData == Void {
    mutating func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID) throws {
        try newEdge(edge, tail: tail, head: head, data: ())
    }
    
    mutating func newEdge(_ edge: EdgeID, tail: NodeID, at index: Int, head: NodeID) throws {
        try newEdge(edge, tail: tail, at: index, head: head, data: ())
    }
}

public extension EditableGraphBase where GraphData == Empty {
    var data: Empty {
        get { Empty() }
        set { }
    }
}

public extension EditableGraphBase where GraphData == Void {
    var data: Void {
        get { () }
        set { }
    }
}
