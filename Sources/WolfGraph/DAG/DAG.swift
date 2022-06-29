import Foundation

public struct DAG<InnerGraph>: ViewableDAG
where InnerGraph: ViewableGraph
{
    public typealias NodeID = InnerGraph.NodeID
    public typealias EdgeID = InnerGraph.EdgeID
    public typealias NodeData = InnerGraph.NodeData
    public typealias EdgeData = InnerGraph.EdgeData
    
    public let innerGraph: InnerGraph
    
    public init(innerGraph: InnerGraph) throws {
        guard try innerGraph.isDAG() else {
            throw GraphError.notADAG
        }
        self.innerGraph = innerGraph
    }
}

extension DAG: EditableDAG, EditableGraph
where InnerGraph: EditableGraph
{
//    public init() {
//        try! self.init(innerGraph: InnerGraph())
//    }
    
    init(uncheckedInnerGraph: InnerGraph) {
        self.innerGraph = uncheckedInnerGraph
    }

    public func copySettingInnerGraph(_ innerGraph: InnerGraph) -> DAG<InnerGraph> {
        Self(uncheckedInnerGraph: innerGraph)
    }
    
    public func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws -> DAG<InnerGraph> {
        guard try canAddDAGEdge(from: tail, to: head) else {
            throw GraphError.notADAG
        }
        return try copySettingInnerGraph(innerGraph
            .newEdge(edge, tail: tail, head: head, data: data)
        )
    }
    
    public func moveEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws -> DAG<InnerGraph> {
        guard try canMoveDAGEdge(edge, newTail: newTail, newHead: newHead) else {
            throw GraphError.notADAG
        }
        return try copySettingInnerGraph(innerGraph
            .moveEdge(edge, newTail: newTail, newHead: newHead)
        )
    }
}
