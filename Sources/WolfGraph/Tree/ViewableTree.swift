import Foundation

public protocol ViewableTree: ViewableGraph {
    var root: NodeID { get }

    func inEdge(_ node: NodeID) throws -> EdgeID?
    func parent(_ node: NodeID) throws -> NodeID?
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
}
