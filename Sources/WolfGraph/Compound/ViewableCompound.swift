import Foundation

public protocol ViewableCompound: ViewableGraph
where EdgeID == InnerTree.EdgeID, NodeID == InnerTree.NodeID
{
    associatedtype InnerTree: ViewableTree
    
    var root: NodeID { get }
    var tree: InnerTree { get }

    //
    // Queries the tree
    //
    
    func inEdge(_ node: NodeID) throws -> EdgeID?
    func parent(_ node: NodeID) throws -> NodeID?
}

public extension ViewableCompound {
    func inEdge(_ node: NodeID) throws -> EdgeID? {
        try tree.nodeInEdges(node).first
    }

    func parent(_ node: NodeID) throws -> NodeID? {
        guard let e = try tree.inEdge(node) else {
            return nil
        }
        return try! tree.edgeTail(e)
    }
}
