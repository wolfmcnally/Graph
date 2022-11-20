import Foundation
import WolfBase
import Collections
import SortedCollections

//// Based on Python implementation:
//// https://github.com/timtadh/zhang-shasha
//
//public func compareTrees<T: ViewableTree>(
//    a: T, aRoot: T.NodeID? = nil,
//    b: T, bRoot: T.NodeID? = nil,
//    insertCost: (T.NodeData) -> Double,
//    removeCost: (T.NodeData) -> Double,
//    updateCost: (T.NodeData, T.NodeData) -> Double
//) throws {
//    let aRoot = aRoot ?? a.root
//    let bRoot = bRoot ?? b.root
//    let A = AnnotatedTree(a)
//    let B = AnnotatedTree(b)
//}
//
//struct AnnotatedTree<T: ViewableTree> {
//    typealias NodeID = T.NodeID
//    
//    let tree: T
//    let nodes: [NodeID] // a post-order enumeration of the nodes in the tree
//    let lmds: [NodeID] // left-most descendents
//    let keyroots: [NodeID]
//        /// k and k' are nodes specified in the post-order enumeration.
//        /// keyroots = {k | there exists no k'>k such that lmd(k) == lmd(k')}
//        /// see paper for more on keyroots
//
//    init(_ tree: T, root: NodeID) throws {
//        self.tree = tree
//
//        var stack: [(NodeID, Deque<NodeID>)] = [(root, Deque())]
//        var pstack: [((NodeID, NodeID), Deque<NodeID>)] = []
//        let treeNodes = tree.nodes
//        
//        var j = treeNodes.startIndex
//        while !stack.isEmpty {
//            let (n, anc) = stack.popLast()!
//            let nid = treeNodes[j]
//            for c in try tree.children(n) {
//                var a = anc
//                a.prepend(nid)
//                stack.append((c, a))
//            }
//            pstack.append(((n, nid), anc))
//            j = treeNodes.index(after: j)
//        }
//        
//        var nodes: [NodeID] = []
//        var ids: [NodeID] = []
//        var lmds: [NodeID] = []
//        var _lmds: [NodeID: SortedSet<NodeID>.Index] = [:]
//        var i = treeNodes.startIndex
//        while !pstack.isEmpty {
//            let ((n, nid), anc) = pstack.popLast()!
//            nodes.append(n)
//            ids.append(nid)
//            var lmd: SortedSet<NodeID>.Index
//            if try !tree.hasChildren(n) {
//                lmd = i
//                for a in anc {
//                    if _lmds[a] == nil {
//                        _lmds[a] = i
//                    } else {
//                        break
//                    }
//                }
//            } else {
//                lmd = _lmds[nid]!
//            }
//            lmds.append(lmd)
//        }
//        self.lmds = lmds
//        todo()
//    }
//}
