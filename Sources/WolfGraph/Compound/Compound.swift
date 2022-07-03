import Foundation

//
// A compound graph is a graph with a parallel tree that puts the nodes of the
// graph into a hierarchy.
//
// The sets of edges of the graph and the tree are disjoint. The set of nodes
// between the graph and the tree is identical, except the tree also has a root
// node.
//

public struct Compound<InnerGraph, InnerTree>: EditableCompound, EditableGraphWrapper
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

    public var root: NodeID {
        tree.root
    }
}

// MARK: - EditableCompound Implementations

extension Compound
{
    /// Adding a node inserts it into both the graph and the tree, as a child of the specified `parent`.
    public mutating func newNode(_ node: NodeID, data: NodeData, parent: NodeID, edge: EdgeID) throws {
        try graph.newNode(node, data: data)
        try tree.newNode(node, parent: parent, edge: edge)
    }

    /// Removing a node first promotes all its tree children to its parent,
    /// then removes it from both the tree and the graph.
    public mutating func removeNode(_ node: NodeID) throws {
        try graph.removeNode(node)
        try tree.removeNodeUngrouping(node)
    }

    /// Moves a node within the tree
    public mutating func moveNode(_ node: NodeID, newParent: NodeID) throws {
        try tree.moveNode(node, newParent: newParent)
    }

    /// Inserts an edge within the graph
    public mutating func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws {
        try graph.newEdge(edge, tail: tail, head: head, data: data)
    }

    /// Removes an edge from the graph
    public mutating func removeEdge(_ edge: EdgeID) throws {
        try graph.removeEdge(edge)
    }

    /// Removes all edges from a node in the graph
    public mutating func removeNodeEdges(_ node: NodeID) throws {
        try graph.removeNodeEdges(node)
    }

    /// Moves an edge within the graph
    public mutating func moveEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws {
        try graph.moveEdge(edge, newTail: newTail, newHead: newHead)
    }
}
