import Foundation

public struct DAG<InnerGraph>: ViewableDAG
where InnerGraph: ViewableGraph
{
    public typealias NodeID = InnerGraph.NodeID
    public typealias EdgeID = InnerGraph.EdgeID
    public typealias NodeData = InnerGraph.NodeData
    public typealias EdgeData = InnerGraph.EdgeData
    
    public let graph: InnerGraph
    
    public init(graph: InnerGraph) throws {
        guard try graph.isDAG() else {
            throw GraphError.notADAG
        }
        self.graph = graph
    }
}

extension DAG: EditableDAG, EditableGraphBase, EditableGraph
where InnerGraph: EditableGraph
{
    init(uncheckedInnerGraph: InnerGraph) {
        self.graph = uncheckedInnerGraph
    }

    public func copySettingInner(graph: InnerGraph) -> DAG<InnerGraph> {
        Self(uncheckedInnerGraph: graph)
    }
    
    public func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws -> DAG<InnerGraph> {
        guard try canAddDAGEdge(from: tail, to: head) else {
            throw GraphError.notADAG
        }
        return try copySettingInner(graph: graph
            .newEdge(edge, tail: tail, head: head, data: data)
        )
    }
    
    public func moveEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws -> DAG<InnerGraph> {
        guard try canMoveDAGEdge(edge, newTail: newTail, newHead: newHead) else {
            throw GraphError.notADAG
        }
        return try copySettingInner(graph: graph
            .moveEdge(edge, newTail: newTail, newHead: newHead)
        )
    }
}
