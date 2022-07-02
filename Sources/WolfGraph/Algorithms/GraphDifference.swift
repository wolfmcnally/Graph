import Foundation

public struct GraphDifference<G: ViewableGraph> {
    public typealias NodeID = G.NodeID
    public typealias EdgeID = G.EdgeID
    public typealias NodeData = G.NodeData
    public typealias EdgeData = G.EdgeData
    
    // Fields below are listed in order of application. Application must be atomic:
    // the graph's invariants (e.g., Tree, DAG, no multi-edges, etc.) may not hold
    // until all the changes are applied. The order of application does guarantee that
    // exiting nodes will have no remaining incident edges when they are deleted.

    public let enteringNodes: [NodeID: NodeData]
    public let updatingNodes: [NodeID: NodeData]
    public let enteringEdges: [EdgeID: EdgeData]
    public let updatingEdges: [EdgeID: EdgeData]
    public let movingEdges: [EdgeID: (NodeID, NodeID)]
    public let exitingEdges: Set<EdgeID>
    public let exitingNodes: Set<NodeID>
}

public extension ViewableGraph {
    /// Returns the difference needed to produce this graph from the given graph.
    func difference<G>(from other: G) -> GraphDifference<G>
    where G: ViewableGraph,
          NodeID == G.NodeID, EdgeID == G.EdgeID,
          NodeData == G.NodeData, EdgeData == G.EdgeData,
          NodeData: Equatable, EdgeData: Equatable
    {
        let startNodes = Set(other.nodes)
        let endNodes = Set(nodes)

        let enteringNodes: [NodeID: NodeData] = endNodes.subtracting(startNodes).reduce(into: .init()) { result, node in
            result[node] = try! self.nodeData(node)
        }
        let exitingNodes = startNodes.subtracting(endNodes)
        let updatingNodes: [NodeID: NodeData] = startNodes.intersection(endNodes).reduce(into: .init()) { result, node in
            let selfData = try! nodeData(node)
            let otherData = try! other.nodeData(node)
            if selfData != otherData {
                result[node] = selfData
            }
        }
        
        let startEdges = Set(other.edges)
        let endEdges = Set(edges)
        
        let enteringEdges: [EdgeID: EdgeData] = endEdges.subtracting(startEdges).reduce(into: .init()) { result, edge in
            result[edge] = try! self.edgeData(edge)
        }
        let exitingEdges = startEdges.subtracting(endEdges)
        let updatableEdges = startEdges.intersection(endEdges)
        let updatingEdges: [EdgeID: EdgeData] = updatableEdges.reduce(into: .init()) { result, edge in
            let selfData = try! edgeData(edge)
            let otherData = try! other.edgeData(edge)
            if selfData != otherData {
                result[edge] = selfData
            }
        }
        let movingEdges: [EdgeID: (NodeID, NodeID)] = updatableEdges.reduce(into: .init()) { result, edge in
            let selfEnds = try! edgeEnds(edge)
            let otherEnds = try! other.edgeEnds(edge)
            if selfEnds != otherEnds {
                result[edge] = selfEnds
            }
        }
        
        return GraphDifference(
            enteringNodes: enteringNodes,
            updatingNodes: updatingNodes,
            enteringEdges: enteringEdges,
            updatingEdges: updatingEdges,
            movingEdges: movingEdges,
            exitingEdges: exitingEdges,
            exitingNodes: exitingNodes
        )
    }
}
