import XCTest
import Algorithms
import WolfBase
@testable import Graph

fileprivate typealias GraphType = Graph<Int, Int, String, Empty, Empty>
fileprivate typealias TreeType = Tree<GraphType>
fileprivate typealias NodeID = TreeType.NodeID
fileprivate typealias NodeData = TreeType.NodeData

final class TreeEditTest: XCTestCase {
    func testNodes() throws {
        let (A, B) = simpleAnnotatedTrees()
        for (i, nid) in A.ids.reversed().enumerated() {
            XCTAssertEqual(nid, i)
        }
        for (i, nid) in B.ids.reversed().enumerated() {
            XCTAssertEqual(nid, i)
        }
    }
    
    func testLeftMostDescendent() {
        let (A, B) = simpleAnnotatedTrees()
        XCTAssertEqual(A.lmds, [0, 1, 1, 0, 4, 0])
        XCTAssertEqual(B.lmds, [0, 1, 0, 0, 4, 0])
    }
    
    func testKeyRoots() {
        let (A, B) = simpleAnnotatedTrees()
        XCTAssertEqual(A.keyRoots, [2, 4, 5])
        XCTAssertEqual(B.keyRoots, [1, 4, 5])
    }
    
    func testPaperTree() {
        let (a, b) = simpleTrees()
        XCTAssertEqual(distance(from: a, to: b).0, 2)
    }
    
    func testRichAPI() {
        let a = makeTree(root: "a", edges: [])
        let b = makeTree(root: "b", edges: [])
        let insertCost: (NodeData) -> Double = { _ in 1 }
        let removeCost: (NodeData) -> Double = { _ in 1 }
        let smallUpdateCost: (NodeData, NodeData) -> Double = { _, _ in 1 }
        let largeUpdateCost: (NodeData, NodeData) -> Double = { _, _ in 3 }
        let noInsertCost: (NodeData) -> Double = { _ in 0 }
        // prefer update
        XCTAssertEqual(distance(from: a, to: b, insertCost: insertCost, removeCost: removeCost, updateCost: smallUpdateCost).0, 1)
        // prefer insert/remove
        XCTAssertEqual(distance(from: a, to: b, insertCost: insertCost, removeCost: removeCost, updateCost: largeUpdateCost).0, 2)
        
        let c = makeTree(root: "a", edges: [("a", "x")])
        let dist1 = distance(from: a, to: c, insertCost: insertCost, removeCost: removeCost, updateCost: smallUpdateCost).0
        let dist2 = distance(from: a, to: c, insertCost: noInsertCost, removeCost: removeCost, updateCost: smallUpdateCost).0
        XCTAssert(dist1 > dist2)
    }
    
    func testDistance() {
        let trees = [tree1(), tree2(), tree3(), tree4()]
        for(a, b) in product(trees, trees) {
            let ab = distance(from: a, to: b).0
            let ba = distance(from: b, to: a).0
            XCTAssertEqual(ab, ba)
        }
        
        for((a, b), c) in product(product(trees, trees), trees) {
            let ab = distance(from: a, to: b).0
            let bc = distance(from: b, to: c).0
            let ac = distance(from: a, to: c).0
            XCTAssertTrue(ac <= ab + bc)
        }
    }
    
//    func testRandTree() {
//        let t = randTree(depth: 5, labelLen: 3, width: 2)
//        print(t.jsonString(outputFormatting: [.prettyPrinted, .sortedKeys]))
//    }
    
    func testSymmetry() {
        let trees = (0..<3).map { _ in randTree(depth: 5, labelLen: 3, width: 2) }
        for(a, b) in product(trees, trees) {
            let ab = distance(from: a, to: b).0
            let ba = distance(from: b, to: a).0
//            print(ab, ba)
            XCTAssertEqual(ab, ba)
        }
    }
    
    func testNondegeneracy() {
        let trees = (0..<3).map { _ in randTree(depth: 5, labelLen: 3, width: 2) }
        for(a, b) in product(trees, trees) {
            let d = distance(from: a, to: b).0
//            print(d, a == b)
            XCTAssertTrue(d == 0 ? a == b : a != b)
        }
    }
    
    func testTriangleInequality() {
        let trees1 = (0..<3).map { _ in randTree(depth: 5, labelLen: 3, width: 2) }
        let trees2 = (0..<3).map { _ in randTree(depth: 5, labelLen: 3, width: 2) }
        let trees3 = (0..<3).map { _ in randTree(depth: 5, labelLen: 3, width: 2) }
        for((a, b), c) in product(product(trees1, trees2), trees3) {
            let ab = distance(from: a, to: b).0
            let bc = distance(from: b, to: c).0
            let ac = distance(from: a, to: c).0
//            print(ab, bc, ac)
            XCTAssertTrue(ac < ab + bc)
        }
    }
    
    func testLabelChange() {
        for a in (0..<12).lazy.map({ _ in randTree(depth: 5, labelLen: 3, width: 2) }) {
            var b = a
            let node = b.nodes.randomElement()!
            let oldLabel = try! b.nodeData(node)
            let newLabel = "xty"
            try! b.withNodeData(node) { label in
                label = newLabel
            }
            let dist = distance(from: a, to: b).0
            let expectedDist: Double = oldLabel == newLabel ? 0 : 1
            XCTAssertEqual(dist, expectedDist)
        }
    }
}

fileprivate func simpleTrees() -> (TreeType, TreeType) {
    let a = makeTree(root: "f", edges: [
        ("f", "d"),
            ("d", "a"),
            ("d", "c"),
                ("c", "b"),
        ("f", "e"),
    ])

    let b = makeTree(root: "f", edges: [
        ("f", "c"),
            ("c", "d"),
                ("d", "a"),
                ("d", "b"),
        ("f", "e")
    ])
    return (a, b)
}

fileprivate func tree1() -> TreeType {
    makeTree(root: "f", edges: [
        ("f", "d"),
            ("d", "a"),
            ("d", "c"),
                ("c", "b"),
        ("f", "e"),
    ])
}

fileprivate func tree2() -> TreeType {
    makeTree(root: "a", edges: [
        ("a", "c"),
            ("c", "d"),
                ("d", "b"),
                ("d", "e"),
        ("a", "f"),
    ])
}

fileprivate func tree4() -> TreeType {
    makeTree(root: "f", edges: [
        ("f", "d"),
            ("d", "q"),
            ("d", "c"),
                ("c", "b"),
        ("f", "e"),
    ])
}

fileprivate func tree3() -> TreeType {
    makeTree(root: "a", edges: [
        ("a", "d"),
            ("d", "f"),
            ("d", "c"),
                ("c", "b"),
        ("a", "e"),
    ])
}

fileprivate let alphabet = "abcdefghijklmnopqrstuvwxyz".map { String($0) }

fileprivate func composeLabels(depth: Int) -> [String] {
    func composeLabels(labels: inout [String], currentLabel: String, curDepth: Int, n: Int) {
        guard curDepth < depth else {
            labels.append(currentLabel)
            return
        }
        for c in alphabet {
            composeLabels(labels: &labels, currentLabel: currentLabel + c, curDepth: curDepth + 1, n: n + 1)
        }
    }
    
    var result: [String] = []
    composeLabels(labels: &result, currentLabel: "", curDepth: 0, n: 0)
    return result
}

fileprivate func randTree(depth: Int, labelLen: Int, width: Int) -> TreeType {
    var rng = SystemRandomNumberGenerator()
    return randTree(depth: depth, labelLen: labelLen, width: width, using: &rng)
}

fileprivate func randTree<R: RandomNumberGenerator>(depth: Int, labelLen: Int, width: Int, using rng: inout R) -> TreeType {
    var labels = composeLabels(depth: labelLen).shuffled(using: &rng)
    
    func nextLabel() -> String {
        return labels.popLast()!
    }
    
    var gen = IDGen(nextNode: 100, nextEdge: 200)
    var t = makeTree(root: "root", edges: [], gen: &gen)
    var p: [NodeID] = [t.root]
    var c: [NodeID] = []
    for _ in 0..<(depth - 1) {
        for y in p {
            for _ in 0..<(Int.random(in: 1...(width + 1), using: &rng)) {
                let n = gen.nextNode
                try! t.newNode(n, parent: y, edge: gen.nextEdge, nodeData: nextLabel())
                c.append(n)
            }
        }
        p = c
        c = []
    }
    
    return t
}

fileprivate func simpleAnnotatedTrees() -> (AnnotatedTree<TreeType>, AnnotatedTree<TreeType>) {
    let (a, b) = simpleTrees()
    return (AnnotatedTree(a), AnnotatedTree(b))
}

fileprivate func makeTree(root: String, edges: [(String, String)]) -> TreeType {
    var gen = IDGen(nextNode: 100, nextEdge: 200)
    return makeTree(root: root, edges: edges, gen: &gen)
}

fileprivate func makeTree(root: String, edges: [(String, String)], gen: inout IDGen) -> TreeType {
    var graph = GraphType()
    let rootID = gen.nextNode
    try! graph.newNode(rootID, data: root)
    var idsByLabel: [String: Int] = [root: rootID]
    var tree = try! TreeType(graph: graph, root: rootID)
    for (parentLabel, childLabel) in edges {
        let parentID = idsByLabel[parentLabel]!
        let childID = gen.nextNode
        idsByLabel[childLabel] = childID
        try! tree.newNode(childID, parent: parentID, edge: gen.nextEdge, nodeData: childLabel)
    }
    return tree
}

struct IDGen {
    private var _nextNode: Int
    private var _nextEdge: Int
    
    init(nextNode: Int = 0, nextEdge: Int = 0) {
        self._nextNode = nextNode
        self._nextEdge = nextEdge
    }
    
    var nextNode: Int {
        mutating get {
            defer { _nextNode += 1 }
            return _nextNode
        }
    }
    
    var nextEdge: Int {
        mutating get {
            defer { _nextEdge += 1 }
            return _nextEdge
        }
    }
}
