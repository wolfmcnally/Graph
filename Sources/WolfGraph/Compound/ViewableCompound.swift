import Foundation

public protocol ViewableCompound: ViewableTree
where NodeID == InnerTree.NodeID, EdgeID == InnerTree.EdgeID
{
    associatedtype InnerTree: ViewableTree
    var innerTree: InnerTree { get }
}

extension ViewableCompound {
    public func inEdge(_ node: NodeID) throws -> EdgeID? {
        try innerTree.inEdge(node)
    }
    
    public func parent(_ node: NodeID) throws -> NodeID? {
        try innerTree.parent(node)
    }
}
