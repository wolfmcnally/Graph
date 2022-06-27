import Foundation

public extension ViewableGraph {
    func isTree(root: NodeID) throws -> Bool {
        try depthFirstSearch(IsTreeVisitor(root: root), roots: [root], isSorted: false)
    }
}

fileprivate class IsTreeVisitor<Graph: ViewableGraph>: DFSVisitor {
    typealias NodeID = Graph.NodeID
    typealias EdgeID = Graph.EdgeID
    
    let root: NodeID
    
    init(root: NodeID) {
        self.root = root
    }
    
    func startNode(_ node: NodeID) -> Bool? {
        node == root ? nil : false
    }
    
    func backEdge(_ edge: EdgeID) -> Bool? { false }
    func forwardOrCrosseEdge(_ edge: EdgeID) -> Bool? { false }
    func finish() -> Bool { true }
}
