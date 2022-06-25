import Foundation

fileprivate enum State {
    case discovered
    case finished
}

public extension ViewableGraph {
    func depthFirstSearch<NodeSequence, Visitor, Result>(roots: NodeSequence, visitor: Visitor, rootsOnly: Bool = false, isSorted: Bool = true, excludedEdge: EdgeID? = nil) -> Result
    where NodeSequence: Sequence<NodeID>, Visitor: DFSVisitor, Visitor.Graph == Self, Result == Visitor.Result
    {
        for node in nodes {
            if let result = visitor.initNode(node) {
                return result
            }
        }
        
        var states: [NodeID: State] = [:]
        
        for root in roots.sortedIf(isSorted) {
            if let result = searchFromRoot(root) {
                return result
            }
        }
        if !rootsOnly {
            for node in nodes.sortedIf(isSorted) {
                if let result = searchFromRoot(node) {
                    return result
                }
            }
        }
        
        return visitor.finish()
        
        func searchFromRoot(_ root: NodeID) -> Result? {
            if states[root] != nil {
                return nil
            }
            if let result = visitor.startNode(root) {
                return result
            }
            states[root] = .discovered
            if let result = visitor.discoverNode(root) {
                return result
            }
            let outEdges = try!
                nodeOutEdges(root)
                .filter {
                    $0 != excludedEdge
                }
                .sortedIf(isSorted)
            var stack: [(NodeID, EdgeID?, [EdgeID])] = []
            stack.append((root, nil, outEdges))
            while let (tail, finishedEdge, remainingOutEdges) = stack.popLast() {
                var tail = tail
                if
                    let finishedEdge,
                    let result = visitor.finishEdge(finishedEdge)
                {
                    return result
                }
                
                var remainingOutEdges = remainingOutEdges
                while let edge = remainingOutEdges.popLast() {
                    let head = try! edgeHead(edge)
                    if let result = visitor.examineEdge(edge) {
                        return result
                    }
                    switch states[head] {
                    case nil:
                        if let result = visitor.treeEdge(edge) {
                            return result
                        }
                        stack.append((tail, edge, remainingOutEdges))
                        tail = head
                        states[tail] = .discovered
                        if let result = visitor.discoverNode(tail) {
                            return result
                        }
                        remainingOutEdges = try! nodeOutEdges(tail).sortedIf(isSorted)
                    case .discovered:
                        if let result = visitor.backEdge(edge) {
                            return result
                        }
                        if let result = visitor.finishEdge(edge) {
                            return result
                        }
                    case .finished:
                        if let result = visitor.forwardOrCrosseEdge(edge) {
                            return result
                        }
                        if let result = visitor.finishEdge(edge) {
                            return result
                        }
                    }
                }
                states[tail] = .finished
                if let result = visitor.finishNode(tail) {
                    return result
                }
            }
            return nil
        }
    }
}
