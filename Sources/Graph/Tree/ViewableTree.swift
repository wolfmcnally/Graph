import Foundation
import SortedCollections
import OrderedCollections

public protocol ViewableTree2: ViewableGraph2 {
    var root: NodeID! { get }

    func inEdge(_ node: NodeID) throws -> EdgeID?
    func parent(_ node: NodeID) throws -> NodeID?
    var nonRootNodes: [NodeID] { get }
    
    func subtree(root: NodeID) throws -> Self
}

public extension ViewableTree2 {
    func inEdge(_ node: NodeID) throws -> EdgeID? {
        try nodeInEdges(node).first
    }

    func parent(_ node: NodeID) throws -> NodeID? {
        guard let e = try inEdge(node) else {
            return nil
        }
        return try! edgeTail(e)
    }
    
    var nonRootNodes: [NodeID] {
        nodes.filter { $0 != root }
    }
    
    func hasChildren(_ node: NodeID) throws -> Bool {
        try hasSuccessors(node)
    }
}

public protocol ViewableTree: ViewableTree2, ViewableGraph {
    func children(_ node: NodeID) throws -> SortedSet<NodeID>
}

public extension ViewableTree {
    func children(_ node: NodeID) throws -> SortedSet<NodeID> {
        try nodeSuccessors(node)
    }
}

public protocol OrderedViewableTree: ViewableTree2, OrderedViewableGraph {
    func children(_ node: NodeID) throws -> OrderedSet<NodeID>
}

public extension OrderedViewableTree {
    func children(_ node: NodeID) throws -> OrderedSet<NodeID> {
        try nodeSuccessors(node)
    }
}
