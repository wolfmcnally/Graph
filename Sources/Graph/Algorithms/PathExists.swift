import Foundation
import WolfBase

public extension ViewableGraph {
    func pathExists(from: NodeID, to: NodeID, excludedEdge: EdgeID? = nil) throws -> Bool {
        let visitor = PathExistsVisitor<Self>(from: from, to: to)
        return try depthFirstSearch(visitor, roots: [from], rootsOnly: false, isSorted: false, excludedEdge: excludedEdge)
    }
    
    func canAddDAGEdge(from: NodeID, to: NodeID, excludedEdge: EdgeID? = nil) throws -> Bool {
        try !pathExists(from: to, to: from, excludedEdge: excludedEdge)
    }
    
    func canMoveDAGEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws -> Bool {
        try canAddDAGEdge(from: newTail, to: newHead, excludedEdge: edge)
    }
}

fileprivate class PathExistsVisitor<Graph: ViewableGraph>: DFSVisitor {
    typealias NodeID = Graph.NodeID
    typealias EdgeID = Graph.EdgeID

    let from: NodeID
    let to: NodeID
    
    init(from: NodeID, to: NodeID) {
        self.from = from
        self.to = to
    }
    
    func discoverNode(_ node: NodeID) throws -> Bool? {
        node == to ? true : nil
    }
    
    func finishNode(_ node: NodeID) throws -> Bool? {
        node == from ? false : nil
    }
    
    func finish() -> Bool {
        false
    }
}
