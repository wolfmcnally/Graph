import Foundation

public struct DAG<InnerGraph>: EditableDAG
where InnerGraph: EditableGraph
{
    public typealias NodeID = InnerGraph.NodeID
    public typealias EdgeID = InnerGraph.EdgeID
    public typealias NodeData = InnerGraph.NodeData
    public typealias EdgeData = InnerGraph.EdgeData
    public typealias GraphData = InnerGraph.GraphData

    public var graph: InnerGraph
    
    public init(graph: InnerGraph) throws {
        guard try graph.isDAG() else {
            throw GraphError.notADAG
        }
        self.graph = graph
    }

    public var data: InnerGraph.GraphData {
        get { graph.data }
        set { graph.data = newValue }
    }
    
    public var isOrdered: Bool {
        graph.isOrdered
    }
}

extension DAG: EditableGraphWrapper
{
    public mutating func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws {
        guard try canAddDAGEdge(from: tail, to: head) else {
            throw GraphError.notADAG
        }
        try graph.newEdge(edge, tail: tail, head: head, data: data)
    }
    
    public mutating func newEdge(_ edge: EdgeID, tail: NodeID, at index: Int, head: NodeID, data: EdgeData) throws {
        guard try canAddDAGEdge(from: tail, to: head) else {
            throw GraphError.notADAG
        }
        try graph.newEdge(edge, tail: tail, at: index, head: head, data: data)
    }

    public mutating func moveEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws {
        guard try canMoveDAGEdge(edge, newTail: newTail, newHead: newHead) else {
            throw GraphError.notADAG
        }
        try graph.moveEdge(edge, newTail: newTail, newHead: newHead)
    }
    
    public mutating func moveEdge(_ edge: EdgeID, newTail: NodeID, at index: Int, newHead: NodeID) throws {
        guard try canMoveDAGEdge(edge, newTail: newTail, newHead: newHead) else {
            throw GraphError.notADAG
        }
        try graph.moveEdge(edge, newTail: newTail, at: index, newHead: newHead)
    }
    
    public mutating func moveEdge(_ edge: EdgeID, to index: Int) throws {
        try graph.moveEdge(edge, to: index)
    }
    
    public mutating func moveEdgeToFront(_ edge: EdgeID) throws {
        try graph.moveEdgeToFront(edge)
    }

    public mutating func moveEdgeToBack(_ edge: EdgeID) throws {
        try graph.moveEdgeToBack(edge)
    }
}
