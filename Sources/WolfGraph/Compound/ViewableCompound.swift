import Foundation

public protocol ViewableCompound: ViewableTree
where NodeID == InnerTree.NodeID, EdgeID == InnerTree.EdgeID
{
    associatedtype InnerGraph: ViewableGraph
    associatedtype InnerTree: ViewableTree
    
    var graph: InnerGraph { get }
    var tree: InnerTree { get }
}

extension ViewableCompound {
    public func inEdge(_ node: NodeID) throws -> EdgeID? {
        try tree.inEdge(node)
    }
    
    public func parent(_ node: NodeID) throws -> NodeID? {
        try tree.parent(node)
    }
}
