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

    public let innerGraph: InnerGraph
    public var innerTree: InnerTree
    
    public var root: NodeID {
        innerTree.root
    }
}

extension Compound
{
    init(uncheckedInnerGraph: InnerGraph, uncheckedInnerTree: InnerTree) {
        self.innerGraph = uncheckedInnerGraph
        self.innerTree = uncheckedInnerTree
    }
    
    public init(graph: InnerGraph, tree: InnerTree) throws {
        guard
            graph.hasNoNode(tree.root),
            Set(tree.nonRootNodes) == Set(graph.nodes)
        else {
            throw GraphError.notACompound
        }
        
        self.innerGraph = graph
        self.innerTree = tree
    }
    
//    public init(graph: InnerGraph, root: NodeID, nextEdgeID: () -> EdgeID) throws {
//        var tree = InnerTree(root: root, data: Empty())
//        for node in graph.nodes {
//            tree = try tree.newNode(node, parent: root, edge: nextEdgeID())
//        }
//        try self.init(graph: graph, tree: tree)
//    }
    
    public func copySettingInnerGraph(_ innerGraph: InnerGraph) -> Self {
        Self(uncheckedInnerGraph: innerGraph, uncheckedInnerTree: innerTree)
    }
}
