import Foundation

public struct DAG<InnerGraph>: ViewableDAG, ViewableGraphWrapper
where InnerGraph: ViewableGraph
{
    public typealias NodeID = InnerGraph.NodeID
    public typealias EdgeID = InnerGraph.EdgeID
    public typealias NodeData = InnerGraph.NodeData
    public typealias EdgeData = InnerGraph.EdgeData
    
    public var graph: InnerGraph
    
    public init(graph: InnerGraph) throws {
        guard try graph.isDAG() else {
            throw GraphError.notADAG
        }
        self.graph = graph
    }
}

extension DAG: EditableDAG, EditableGraphBase, EditableGraph, EditableGraphBaseWrapper, EditableGraphWrapper
where InnerGraph: EditableGraph
{
    public mutating func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws {
        guard try canAddDAGEdge(from: tail, to: head) else {
            throw GraphError.notADAG
        }
        try graph.newEdge(edge, tail: tail, head: head, data: data)
    }
    
    public mutating func moveEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws {
        guard try canMoveDAGEdge(edge, newTail: newTail, newHead: newHead) else {
            throw GraphError.notADAG
        }
        try graph.moveEdge(edge, newTail: newTail, newHead: newHead)
    }
}
