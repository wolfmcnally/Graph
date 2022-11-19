import Foundation
import WolfBase

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
//    let tree: T
//    let nodes: [T.NodeID] // a post-order enumeration of the nodes in the tree
//    let lmds: [T.NodeID] // left-most descendents
//    let keyroots: [T.NodeID]
//        /// k and k' are nodes specified in the post-order enumeration.
//        /// keyroots = {k | there exists no k'>k such that lmd(k) == lmd(k')}
//        /// see paper for more on keyroots
//
//    init(_ tree: T) {
//        self.tree = tree
//        
//        
//    }
//}
