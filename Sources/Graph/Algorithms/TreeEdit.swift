import Foundation
import WolfBase
import Collections
import SortedCollections

// Based on Python implementation:
// https://github.com/timtadh/zhang-shasha

public func distance<T: ViewableTree>(
    from a: T, aRoot: T.NodeID? = nil,
    to b: T, bRoot: T.NodeID? = nil
) -> (Double, [Operation]) where T.NodeData: Equatable {
    distance(
        from: a, aRoot: aRoot,
        to: b, bRoot: bRoot,
        insertCost: { _ in 1 },
        removeCost: { _ in 1 },
        updateCost: { $0 == $1 ? 0 : 1 }
    )
}

public func distance<T: ViewableTree>(
    from a: T, aRoot: T.NodeID? = nil,
    to b: T, bRoot: T.NodeID? = nil,
    insertCost: (T.NodeData) -> Double,
    removeCost: (T.NodeData) -> Double,
    updateCost: (T.NodeData, T.NodeData) -> Double
) -> (Double, [Operation]) {
    typealias NodeID = T.NodeID
    
    let aRoot = aRoot ?? a.root
    let bRoot = bRoot ?? b.root
    let A = AnnotatedTree(a, root: aRoot)
    let B = AnnotatedTree(b, root: bRoot)
    let sizeA = A.nodes.count
    let sizeB = B.nodes.count
    var treedists = Array(repeating: Array(repeating: 0.0, count: sizeB), count: sizeA)
    var operations: [[[Operation]]] = Array(repeating: Array(repeating: [], count: sizeB), count: sizeA)
    
    func _removeCost(_ index: Int) -> Double { removeCost(A.label(index)) }
    func _insertCost(_ index: Int) -> Double { insertCost(B.label(index)) }
    func _updateCost(_ index1: Int, _ index2: Int) -> Double { updateCost(A.label(index1), B.label(index2)) }
    
    func treeDist(_ i: Int, _ j: Int) {
        let Al = A.lmds
        let Bl = B.lmds
        let An = A.nodes
        let Bn = B.nodes

        let m = i - Al[i] + 2
        let n = j - Bl[j] + 2
        var fd = Array(repeating: Array(repeating: 0.0, count: n), count: m)
        var partialOps: [[[Operation]]] = Array(repeating: Array(repeating: [], count: n), count: m)
        
        let ioff = Al[i] - 1
        let joff = Bl[j] - 1
        
        // δ(l(i1)..i, θ) = δ(l(1i)..1-1, θ) + γ(v → λ)
        for x in 1..<m {
            let node = An[x + ioff]
            fd[x][0] = fd[x - 1][0] + _removeCost(node)
            let op = Operation.remove(node)
            partialOps[x][0] = partialOps[x - 1][0].appending(op)
        }
        // δ(θ, l(j1)..j) = δ(θ, l(j1)..j-1) + γ(λ → w)
        for y in 1..<n {
            let node = Bn[y + joff]
            fd[0][y] = fd[0][y - 1] + _insertCost(node)
            let op = Operation.insert(node)
            partialOps[0][y] = partialOps[0][y - 1].appending(op)
        }
        
        for x in 1..<m { // the plus one is for the xrange impl
            for y in 1..<n {
                // x+ioff in the fd table corresponds to the same node as x in
                // the treedists table (same for y and y+joff)
                let node1 = An[x + ioff]
                let node2 = Bn[y + joff]
                // only need to check if x is an ancestor of i
                // and y is an ancestor of j
                if Al[i] == Al[x + ioff] && Bl[j] == Bl[y + joff] {
                    //                   +-
                    //                   | δ(l(i1)..i-1, l(j1)..j) + γ(v → λ)
                    // δ(F1 , F2 ) = min-+ δ(l(i1)..i , l(j1)..j-1) + γ(λ → w)
                    //                   | δ(l(i1)..i-1, l(j1)..j-1) + γ(v → w)
                    //                   +-
                    let costs = [
                        fd[x - 1][y] + _removeCost(node1),
                        fd[x][y - 1] + _insertCost(node2),
                        fd[x - 1][y - 1] + _updateCost(node1, node2)
                    ]
                    fd[x][y] = costs.min()!
                    let minIndex = costs.firstIndex(of: fd[x][y])!
                    
                    switch minIndex {
                    case 0:
                        let op = Operation.remove(node1)
                        partialOps[x][y] = partialOps[x - 1][y].appending(op)
                    case 1:
                        let op = Operation.insert(node2)
                        partialOps[x][y] = partialOps[x][y - 1].appending(op)
                    default:
                        let op: Operation
                        if fd[x][y] == fd[x - 1][y - 1] {
                            op = .match(node1, node2)
                        } else {
                            op = .update(node1, node2)
                        }
                        partialOps[x][y] = partialOps[x - 1][y - 1].appending(op)
                    }
                    
                    operations[x + ioff][y + joff] = partialOps[x][y]
                    treedists[x + ioff][y + joff] = fd[x][y]
                } else {
                    //                   +-
                    //                   | δ(l(i1)..i-1, l(j1)..j) + γ(v → λ)
                    // δ(F1 , F2 ) = min-+ δ(l(i1)..i , l(j1)..j-1) + γ(λ → w)
                    //                   | δ(l(i1)..l(i)-1, l(j1)..l(j)-1)
                    //                   |                     + treedist(i1,j1)
                    //                   +-
                    let p = Al[x + ioff] - 1 - ioff
                    let q = Bl[y + joff] - 1 - joff
                    let costs = [
                        fd[x - 1][y] + _removeCost(node1),
                        fd[x][y - 1] + _insertCost(node2),
                        fd[p][q] + treedists[x + ioff][y + joff]
                    ]
                    fd[x][y] = costs.min()!
                    let minIndex = costs.firstIndex(of: fd[x][y])!
                    switch minIndex {
                    case 0:
                        let op = Operation.remove(node1)
                        partialOps[x][y] = partialOps[x - 1][y].appending(op)
                    case 1:
                        let op = Operation.insert(node2)
                        partialOps[x][y] = partialOps[x][y - 1].appending(op)
                    default:
                        partialOps[x][y] = partialOps[p][q] + operations[x + ioff][y + joff]
                    }
                }
            }
        }
    }
    
    for i in A.keyRoots {
        for j in B.keyRoots {
            treeDist(i, j)
        }
    }
    
    return (
        treedists.last!.last!,
        operations.last!.last!
    )
}

public enum Operation {
    case remove(Int)
    case insert(Int)
    case update(Int, Int)
    case match(Int, Int)
}

struct AnnotatedTree<T: ViewableTree> {
    typealias NodeID = T.NodeID
    
    let tree: T
    let root: NodeID
    let nodeIDForIndex: [Int: NodeID]
    let indexForNodeID: [NodeID: Int]
    let nodes: [Int] // a post-order enumeration of the nodes in the tree
    let ids: [Int] // a matching list of ids
    let lmds: [Int] // left-most descendents
    let keyRoots: [Int]
        /// k and k' are nodes specified in the post-order enumeration.
        /// keyroots = {k | there exists no k'>k such that lmd(k) == lmd(k')}
        /// see paper for more on keyroots

    func label(_ index: Int) -> T.NodeData {
        return try! tree.nodeData(nodeIDForIndex[index]!)
    }
    
    init(_ tree: T, root: NodeID? = nil) {
        self.tree = tree
        let root = root ?? tree.root
        self.root = root

        let treeNodes = Array(tree.nodes)
        let nodeIDForIndex: [Int: NodeID] = treeNodes.enumerated().reduce(into: [:]) { result, indexNode in
            let (index, node) = indexNode
            result[index] = node
        }
        let indexForNodeID: [NodeID: Int] = treeNodes.enumerated().reduce(into: [:]) { result, indexNode in
            let (index, node) = indexNode
            result[node] = index
        }

        let rootIndex = indexForNodeID[root]!
        var stack: [(Int, Deque<Int>)] = [(rootIndex, Deque())]
        var pstack: [((Int, Int), Deque<Int>)] = []
        
        func children(_ index: Int) -> [Int] {
            let node = nodeIDForIndex[index]!
            return try! tree.children(node).map {
                indexForNodeID[$0]!
            }
        }
        
        func hasChildren(_ index: Int) -> Bool {
            try! tree.hasChildren(nodeIDForIndex[index]!)
        }
        
        var j = 0
        while !stack.isEmpty {
            let (n, anc) = stack.popLast()!
            let nid = j
            for c in children(n) {
                var a = anc
                a.prepend(nid)
                stack.append((c, a))
            }
            pstack.append(((n, nid), anc))
            j += 1
        }
        
        var nodes: [Int] = []
        var ids: [Int] = []
        var lmds: [Int] = []
        var _lmds: [Int: Int] = [:]
        var keyRoots: [Int: Int] = [:]
        var i = 0
        while !pstack.isEmpty {
            let ((n, nid), anc) = pstack.popLast()!
            nodes.append(n)
            ids.append(nid)
            var lmd: Int
            if !hasChildren(n) {
                lmd = i
                for a in anc {
                    if _lmds[a] == nil {
                        _lmds[a] = i
                    } else {
                        break
                    }
                }
            } else {
                lmd = _lmds[nid]!
            }
            lmds.append(lmd)
            keyRoots[lmd] = i
            i += 1
        }
        self.indexForNodeID = indexForNodeID
        self.nodeIDForIndex = nodeIDForIndex
        self.ids = ids
        self.lmds = lmds
        self.nodes = nodes
        self.keyRoots = keyRoots.values.sorted()
    }
}
