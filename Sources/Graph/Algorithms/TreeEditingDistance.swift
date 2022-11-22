import Foundation
import WolfBase
import Collections
import SortedCollections

// Based on the algorithm:
// Kaizhong Zhang and Dennis Shasha. Simple fast algorithms for the editing distance between trees and related problems. SIAM Journal of Computing, 18:1245–1262, 1989
// https://grantjenks.com/wiki/_media/ideas/simple_fast_algorithms_for_the_editing_distance_between_tree_and_related_problems.pdf

// Based on Python implementation:
// https://github.com/timtadh/zhang-shasha

public func editingDistance<T: ViewableTree>(from a: T, to b: T, filterMatches: Bool = true) -> (cost: Double, ops: [Operation<T>]) where T.NodeData: Equatable {
    editingDistance(from: a, to: b, filterMatches: filterMatches,
        insertCost: { _ in 1 },
        removeCost: { _ in 1 },
        updateCost: { $0 == $1 ? 0 : 1 }
    )
}

public func editingDistance<T: ViewableTree>(from a: T, to b: T, filterMatches: Bool = true,
    insertCost: (T.NodeData) -> Double,
    removeCost: (T.NodeData) -> Double,
    updateCost: (T.NodeData, T.NodeData) -> Double
) -> (cost: Double, ops: [Operation<T>]) {
    typealias NodeID = T.NodeID
    
    let A = AnnotatedTree(a)
    let B = AnnotatedTree(b)
    let sizeA = A.nodes.count
    let sizeB = B.nodes.count
    var treedists = Array(repeating: Array(repeating: 0.0, count: sizeB), count: sizeA)
    var operations: [[[Operation<T>]]] = Array(repeating: Array(repeating: [], count: sizeB), count: sizeA)
    
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
        var partialOps: [[[Operation<T>]]] = Array(repeating: Array(repeating: [], count: n), count: m)
        
        let ioff = Al[i] - 1
        let joff = Bl[j] - 1
        
        // δ(l(i1)..i, θ) = δ(l(1i)..1-1, θ) + γ(v → λ)
        for x in 1..<m {
            let node = An[x + ioff]
            fd[x][0] = fd[x - 1][0] + _removeCost(node)
            let aNode = A.nodeIDForIndex[node]!
            let aData = try! A.tree.nodeData(aNode)
            let op = Operation<T>.remove(node, aData: aData)
            partialOps[x][0] = partialOps[x - 1][0].appending(op)
        }
        // δ(θ, l(j1)..j) = δ(θ, l(j1)..j-1) + γ(λ → w)
        for y in 1..<n {
            let node1 = An[1 + ioff]
            let node2 = Bn[y + joff]
            fd[0][y] = fd[0][y - 1] + _insertCost(node2)
            let bData = try! B.tree.nodeData(B.nodeIDForIndex[node2]!)
            let op = Operation<T>.insert(node1, bData: bData)
            partialOps[0][y] = partialOps[0][y - 1].appending(op)
        }
        
        for x in 1..<m { // the plus one is for the xrange impl
            for y in 1..<n {
                // x+ioff in the fd table corresponds to the same node as x in
                // the treedists table (same for y and y+joff)
                let node1 = An[x + ioff]
                let node2 = Bn[y + joff]
                let aNode = A.nodeIDForIndex[node1]!
                let aData = try! A.tree.nodeData(aNode)
                let bNode = B.nodeIDForIndex[node2]!
                let bData = try! B.tree.nodeData(bNode)
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
                        let op = Operation<T>.remove(node1, aData: aData)
                        partialOps[x][y] = partialOps[x - 1][y].appending(op)
                    case 1:
                        let op = Operation<T>.insert(node1, bData: bData)
                        partialOps[x][y] = partialOps[x][y - 1].appending(op)
                    default:
                        let op: Operation<T>
                        if fd[x][y] == fd[x - 1][y - 1] {
                            op = .match(node1, abData: aData)
                        } else {
                            op = .update(node1, bData: bData)
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
                        let op = Operation<T>.remove(node1, aData: aData)
                        partialOps[x][y] = partialOps[x - 1][y].appending(op)
                    case 1:
                        let op = Operation<T>.insert(node1, bData: bData)
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
    
    let distance = treedists.last!.last!
    var ops = operations.last!.last!
    if filterMatches {
        ops = ops.filter {
            if case .match = $0 {
                return false
            } else {
                return true
            }
        }
    }
    
    return (
        distance,
        ops
    )
}

public enum Operation<T: ViewableTree>: CustomStringConvertible {
    case remove(Int, aData: T.NodeData)
    case insert(Int, bData: T.NodeData)
    case update(Int, bData: T.NodeData)
    case match(Int, abData: T.NodeData)
    
    public var description: String {
        var comps: [Any] = []
        switch self {
        case .remove(let aNode, let aData):
            comps.append(contentsOf: ["remove", aNode, aData])
        case .insert(let aNode, let bData):
            comps.append(contentsOf: ["insert", aNode, bData])
        case .update(let aNode, let bData):
            comps.append(contentsOf: ["update", aNode, bData])
        case .match(let aNode, let abData):
            comps.append(contentsOf: ["match", aNode, abData])
        }
        return comps.map({ "\($0)" }).joined(separator: ", ").flanked("(", ")")
    }
}

struct AnnotatedTree<T: ViewableTree> {
    typealias NodeID = T.NodeID
    
    let tree: T
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
    
    init(_ tree: T) {
        self.tree = tree

        let treeNodes = Array(tree.nodes)
        let nodeIDForIndex: [Int: NodeID] = treeNodes.enumerated().reduce(into: [:]) { result, indexNode in
            let (index, node) = indexNode
            result[index] = node
        }
        let indexForNodeID: [NodeID: Int] = treeNodes.enumerated().reduce(into: [:]) { result, indexNode in
            let (index, node) = indexNode
            result[node] = index
        }

        let rootIndex = indexForNodeID[tree.root]!
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

public extension EditableTree where NodeData: Equatable {
    func editingOperations(to other: Self) -> [Operation<Self>] {
        editingDistance(from: self, to: other).ops
    }
    
    func applyEditingOperations(_ ops: [Operation<Self>], nextNodeID: () -> NodeID, nextEdgeID: () -> EdgeID, makeEdgeData: () -> EdgeData, callback: ((Operation<Self>, Self) -> Void)? = nil) throws -> Self {
        var result = self
        let t = AnnotatedTree(self)
        
        func nodeID(_ index: Int) throws -> NodeID {
            guard let node = t.nodeIDForIndex[index] else {
                throw GraphError.invalidEditingOperation
            }
            return node
        }
        for op in ops {
            switch op {
            case .remove(let index, _):
                try result.removeNodeUngrouping(nodeID(index))
            case .insert(let index, let bData):
                try result.insertNode(nextNodeID(), before: nodeID(index), edge: nextEdgeID(), nodeData: bData, edgeData: makeEdgeData())
            case .update(let index, let bData):
                try result.withNodeData(nodeID(index)) {
                    $0 = bData
                }
            case .match(_, _):
                break
            }
            
            if let callback {
                callback(op, result)
            }
        }
        return result
    }
}
