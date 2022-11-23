import Foundation

//
// A compound graph is a graph with a parallel tree that puts the nodes of the
// graph into a hierarchy.
//
// The sets of edges of the graph and the tree are disjoint. The set of nodes
// between the graph and the tree is identical, except the tree also has a root
// node.
//

public struct Compound<InnerGraph, InnerTree>: EditableCompound, EditableGraphBaseWrapper
where InnerGraph: EditableGraph,
      InnerTree: EditableTree,
      InnerGraph.NodeID == InnerTree.NodeID,
      InnerGraph.EdgeID == InnerTree.EdgeID,
      InnerTree.NodeData == Empty,
      InnerTree.EdgeData == Empty
{
    public typealias NodeID = InnerGraph.NodeID
    public typealias EdgeID = InnerGraph.EdgeID
    public typealias NodeData = InnerGraph.NodeData
    public typealias EdgeData = InnerGraph.EdgeData

    public var graph: InnerGraph
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

    public var root: NodeID! {
        tree.root
    }
    
    public var data: InnerGraph.GraphData {
        get { graph.data }
        set { graph.data = newValue }
    }
    
    public func subtree(root: InnerGraph.NodeID) throws -> Compound<InnerGraph, InnerTree> {
        try Self(graph: graph, tree: tree.subtree(root: root))
    }
}

// MARK: - EditableCompound Implementations

public extension Compound
{
    /// Adding a node inserts it into both the graph and the tree, as a child of the specified `parent`.
    mutating func newNode(_ node: NodeID, data: NodeData, parent: NodeID, edge: EdgeID) throws {
        try graph.newNode(node, data: data)
        try tree.newNode(node, parent: parent, edge: edge)
    }

    /// Removing a node first promotes all its tree children to its parent,
    /// then removes it from both the tree and the graph.
    mutating func removeNode(_ node: NodeID) throws {
        try graph.removeNode(node)
        try tree.removeNodeUngrouping(node)
    }

    /// Moves a node within the tree.
    mutating func moveNode(_ node: NodeID, newParent: NodeID) throws {
        try tree.moveNode(node, newParent: newParent)
    }

    /// Inserts an edge within the graph.
    mutating func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws {
        try graph.newEdge(edge, tail: tail, head: head, data: data)
    }
    
    /// Inserts an edge within the graph.
    ///
    /// In an ordered graph, the edge will be inserted into tail's outEdges at `index`.
    mutating func newEdge(_ edge: EdgeID, tail: NodeID, at index: Int, head: NodeID, data: EdgeData) throws {
        try graph.newEdge(edge, tail: tail, at: index, head: head, data: data)
    }

    /// Removes an edge from the graph.
    mutating func removeEdge(_ edge: EdgeID) throws {
        try graph.removeEdge(edge)
    }

    /// Removes all edges from a node in the graph.
    mutating func removeNodeEdges(_ node: NodeID) throws {
        try graph.removeNodeEdges(node)
    }

    /// Moves an edge within the graph.
    mutating func moveEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws {
        try graph.moveEdge(edge, newTail: newTail, newHead: newHead)
    }
    
    /// Moves an edge within the graph.
    ///
    /// In an ordered graph, the edge will be inserted into tail's outEdges at `index`.
    mutating func moveEdge(_ edge: EdgeID, newTail: NodeID, at index: Int, newHead: NodeID) throws {
        try graph.moveEdge(edge, newTail: newTail, at: index, newHead: newHead)
    }

    /// Moves an edge to the `index` in the sibling ordering.
    ///
    /// Throws an exception if the graph is not ordered.
    mutating func moveEdge(_ edge: EdgeID, to index: Int) throws {
        try graph.moveEdge(edge, to: index)
    }
    
    /// Moves an edge to the first in the sibling ordering.
    ///
    /// Throws an exception if the graph is not ordered.
    mutating func moveEdgeToFront(_ edge: EdgeID) throws {
        try graph.moveEdgeToFront(edge)
    }

    /// Moves an edge to the last in the sibling ordering.
    ///
    /// Throws an exception if the graph is not ordered.
    mutating func moveEdgeToBack(_ edge: EdgeID) throws {
        try graph.moveEdgeToBack(edge)
    }
}
