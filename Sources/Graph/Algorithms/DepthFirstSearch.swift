import Foundation
import SortedCollections

fileprivate enum State {
    case discovered
    case finished
}

public extension ViewableGraph {
    func depthFirstSearch<Visitor, Result>(_ visitor: Visitor, roots: SortedSet<NodeID> = [], rootsOnly: Bool = false, excludedEdge: EdgeID? = nil) throws -> Result
    where Visitor: DFSVisitor, Visitor.Graph == Self, Result == Visitor.Result
    {
        for node in nodes {
            if let result = try visitor.initNode(node) {
                return result
            }
        }
        
        var states: [NodeID: State] = [:]
        
        for root in roots {
            if let result = try searchFromRoot(root) {
                return result
            }
        }
        if !rootsOnly {
            for node in nodes {
                if let result = try searchFromRoot(node) {
                    return result
                }
            }
        }
        
        return visitor.finish()
        
        func searchFromRoot(_ root: NodeID) throws -> Result? {
            if states[root] != nil {
                return nil
            }
            if let result = try visitor.startNode(root) {
                return result
            }
            states[root] = .discovered
            if let result = try visitor.discoverNode(root) {
                return result
            }
            let outEdges = try
                nodeOutEdges(root)
                .filter {
                    $0 != excludedEdge
                }
            var stack: [(NodeID, EdgeID?, SortedSet<EdgeID>)] = []
            stack.append((root, nil, outEdges))
            while let (tail, finishedEdge, remainingOutEdges) = stack.popLast() {
                var tail = tail
                if
                    let finishedEdge,
                    let result = try visitor.finishEdge(finishedEdge)
                {
                    return result
                }
                
                var remainingOutEdges = remainingOutEdges
                while let edge = remainingOutEdges.popLast() {
                    let head = try edgeHead(edge)
                    if let result = try visitor.examineEdge(edge) {
                        return result
                    }
                    switch states[head] {
                    case nil:
                        if let result = try visitor.treeEdge(edge) {
                            return result
                        }
                        stack.append((tail, edge, remainingOutEdges))
                        tail = head
                        states[tail] = .discovered
                        if let result = try visitor.discoverNode(tail) {
                            return result
                        }
                        remainingOutEdges = try nodeOutEdges(tail)
                    case .discovered:
                        if let result = try visitor.backEdge(edge) {
                            return result
                        }
                        if let result = try visitor.finishEdge(edge) {
                            return result
                        }
                    case .finished:
                        if let result = try visitor.forwardOrCrosseEdge(edge) {
                            return result
                        }
                        if let result = try visitor.finishEdge(edge) {
                            return result
                        }
                    }
                }
                states[tail] = .finished
                if let result = try visitor.finishNode(tail) {
                    return result
                }
            }
            return nil
        }
    }
}
