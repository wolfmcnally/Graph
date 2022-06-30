import Foundation

//
// A compound graph is a graph with a parallel tree that puts the nodes of the
// graph into a hierarchy.
//
// The sets of edges of the graph and the tree are disjoint. The set of nodes
// between the graph and the tree is identical, except the tree also has a root
// node.
//

public struct Compound<InnerGraph, InnerTree>: EditableCompound
where InnerGraph: EditableGraph, InnerTree: EditableTree, InnerGraph.NodeID == InnerTree.NodeID, InnerGraph.EdgeID == InnerTree.EdgeID, InnerTree.NodeData == Empty, InnerTree.EdgeData == Empty
{
    public typealias NodeID = InnerGraph.NodeID
    public typealias EdgeID = InnerGraph.EdgeID
    public typealias NodeData = InnerGraph.NodeData
    public typealias EdgeData = InnerGraph.EdgeData

    public let graph: InnerGraph
    public var tree: InnerTree

    public init(graph: InnerGraph, tree: InnerTree) throws {
        guard
            graph.hasNoNode(tree.root),
            Set(tree.nonRootNodes) == Set(graph.nodes)
        else {
            throw GraphError.notACompound
        }
        
        self.graph = graph
        self.tree = tree
    }

    public var root: NodeID {
        tree.root
    }
}

extension Compound: EditableGraphBase {
    init(uncheckedInnerGraph: InnerGraph, uncheckedInnerTree: InnerTree) {
        self.graph = uncheckedInnerGraph
        self.tree = uncheckedInnerTree
    }
    
    public func copySettingInner(graph: InnerGraph) -> Self {
        Self(uncheckedInnerGraph: graph, uncheckedInnerTree: tree)
    }
    
    public func copySettingInner(graph: InnerGraph, tree: InnerTree) -> Self {
        Self(uncheckedInnerGraph: graph, uncheckedInnerTree: tree)
    }
    
    /// Adding a node inserts it into both the graph and the tree, as a child of the specified `parent`.
    public func newNode(_ node: NodeID, data: NodeData, parent: NodeID, edge: EdgeID) throws -> Self {
        try Self(
            uncheckedInnerGraph: graph.newNode(node, data: data),
            uncheckedInnerTree: tree.newNode(node, parent: parent, edge: edge)
        )
    }

    /// Removing a node first promotes all its tree children to its parent,
    /// then removes it from both the tree and the graph.
    public func removeNode(_ node: NodeID) throws -> Self {
        try Self(
            uncheckedInnerGraph: graph.removeNode(node),
            uncheckedInnerTree: tree.removeNodeUngrouping(node)
        )
    }
    
    /// Moves a node within the tree
    public func moveNode(_ node: NodeID, newParent: NodeID) throws -> Self {
        try Self(
            uncheckedInnerGraph: graph,
            uncheckedInnerTree: tree.moveNode(node, newParent: newParent)
        )
    }
    
    /// Inserts an edge within the graph
    public func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws -> Self {
        try Self(
            uncheckedInnerGraph: graph.newEdge(edge, tail: tail, head: head, data: data),
            uncheckedInnerTree: tree
        )
    }
    
    /// Removes an edge from the graph
    public func removeEdge(_ edge: EdgeID) throws -> Self {
        try Self(
            uncheckedInnerGraph: graph.removeEdge(edge),
            uncheckedInnerTree: tree
        )
    }
    
    /// Removes all edges from a node in the graph
    public func removeNodeEdges(_ node: NodeID) throws -> Self {
        try Self(
            uncheckedInnerGraph: graph.removeNodeEdges(node),
            uncheckedInnerTree: tree
        )
    }
    
    /// Moves an edge within the graph
    public func moveEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws -> Self {
        try Self(
            uncheckedInnerGraph: graph.moveEdge(edge, newTail: newTail, newHead: newHead),
            uncheckedInnerTree: tree
        )
    }
}
