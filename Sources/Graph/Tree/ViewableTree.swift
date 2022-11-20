import Foundation
import SortedCollections

public protocol ViewableTree: ViewableGraph {
    var root: NodeID { get }

    func inEdge(_ node: NodeID) throws -> EdgeID?
    func parent(_ node: NodeID) throws -> NodeID?
    var nonRootNodes: [NodeID] { get }
}

public extension ViewableTree {
    func inEdge(_ node: NodeID) throws -> EdgeID? {
        try nodeInEdges(node).first
    }

    func parent(_ node: NodeID) throws -> NodeID? {
        guard let e = try inEdge(node) else {
            return nil
        }
        return try! edgeTail(e)
    }
    
    func children(_ node: NodeID) throws -> SortedSet<NodeID> {
        try nodeSuccessors(node)
    }
    
    func hasChildren(_ node: NodeID) throws -> Bool {
        try hasSuccessors(node)
    }
    
    var nonRootNodes: [NodeID] {
        nodes.filter { $0 != root }
    }
}
