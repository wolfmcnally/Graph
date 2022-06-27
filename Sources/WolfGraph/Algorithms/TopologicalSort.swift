import Foundation
import WolfBase

public extension ViewableGraph {
    func topologicalSort(roots: [NodeID] = [], rootsOnly: Bool = false, isSorted: Bool = true) throws -> [NodeID] {
        let visitor = TopologicalSortVisitor<Self>(capacity: nodesCount)
        try depthFirstSearch(visitor, roots: roots, rootsOnly: rootsOnly, isSorted: isSorted)
        return visitor.nodes
    }
    
    func isDAG() throws -> Bool {
        do {
            _ = try topologicalSort(isSorted: false)
        } catch GraphError.notADAG {
            return false
        } catch {
            throw error
        }
        return true
    }
}

fileprivate class TopologicalSortVisitor<Graph: ViewableGraph>: DFSVisitor {
    typealias NodeID = Graph.NodeID
    typealias EdgeID = Graph.EdgeID

    var nodes: [NodeID] = []

    init(capacity: Int) {
        self.nodes.reserveCapacity(capacity)
    }
    
    func backEdge(_ edge: EdgeID) throws -> ()? {
        throw GraphError.notADAG
    }
    
    func finishNode(_ node: NodeID) -> ()? {
        nodes.append(node)
        return nil
    }
    
    func finish() -> () {
    }
}
