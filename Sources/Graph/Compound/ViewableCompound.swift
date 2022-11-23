import Foundation

public protocol ViewableCompound: ViewableTree
where NodeID == InnerTree.NodeID, EdgeID == InnerTree.EdgeID, InnerTree.NodeID == InnerGraph.NodeID, InnerTree.EdgeID == InnerGraph.EdgeID
{
    associatedtype InnerGraph: ViewableGraph
    associatedtype InnerTree: ViewableTree
    
    var graph: InnerGraph { get }
    var tree: InnerTree { get }
}

public extension ViewableCompound {
    func inEdge(_ node: NodeID) throws -> EdgeID? {
        try tree.inEdge(node)
    }
    
    func parent(_ node: NodeID) throws -> NodeID? {
        try tree.parent(node)
    }

    func treeEdgeIndex(_ edge: EdgeID) throws -> Int {
        try tree.edgeIndex(edge)
    }
}
