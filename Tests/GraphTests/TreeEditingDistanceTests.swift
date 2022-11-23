import XCTest
import Algorithms
import WolfBase
@testable import Graph

fileprivate typealias GraphType = Graph<Int, Int, String, Empty, Empty>
fileprivate typealias TreeType = Tree<GraphType>
fileprivate typealias NodeID = TreeType.NodeID
fileprivate typealias EdgeID = TreeType.EdgeID
fileprivate typealias NodeData = TreeType.NodeData

extension TreeType {
    var format: String {
        var result: [String] = []
        format(level: 0, node: root, result: &result)
        return result.joined(separator: "\n")
    }
    
    private func format(level: Int, node: NodeID, result: inout [String]) {
        let indent = String(repeating: " ", count: level * 2)
        let label = try! self.nodeData(node)
        result.append(indent + label)
        for child in try! children(node) {
            format(level: level + 1, node: child, result: &result)
        }
    }
}

final class TreeEditingDistanceTest: XCTestCase {
    func testNodes() throws {
        let (a, b) = simpleAnnotatedTrees()
        for (i, nid) in a.ids.reversed().enumerated() {
            XCTAssertEqual(nid, i)
        }
        for (i, nid) in b.ids.reversed().enumerated() {
            XCTAssertEqual(nid, i)
        }
    }
    
    func testLeftMostDescendent() {
        let (a, b) = simpleAnnotatedTrees()
        XCTAssertEqual(a.lmds, [0, 1, 1, 0, 4, 0])
        XCTAssertEqual(b.lmds, [0, 1, 0, 0, 4, 0])
    }
    
    func testKeyRoots() {
        let (a, b) = simpleAnnotatedTrees()
        XCTAssertEqual(a.keyRoots, [2, 4, 5])
        XCTAssertEqual(b.keyRoots, [1, 4, 5])
    }
    
    func testPaperTree() throws {
        let (a, b) = simpleTrees()
        XCTAssertEqual(try editingDistance(from: a, to: b).cost, 2)
    }
    
    func testRichAPI() throws {
        let a = makeTree(root: "a", edges: [])
        let b = makeTree(root: "b", edges: [])
        let insertCost: (NodeData) -> Double = { _ in 1 }
        let removeCost: (NodeData) -> Double = { _ in 1 }
        let smallUpdateCost: (NodeData, NodeData) -> Double = { _, _ in 1 }
        let largeUpdateCost: (NodeData, NodeData) -> Double = { _, _ in 3 }
        let noInsertCost: (NodeData) -> Double = { _ in 0 }
        // prefer update
        XCTAssertEqual(try editingDistance(from: a, to: b, insertCost: insertCost, removeCost: removeCost, updateCost: smallUpdateCost).cost, 1)
        // prefer insert/remove
        XCTAssertEqual(try editingDistance(from: a, to: b, insertCost: insertCost, removeCost: removeCost, updateCost: largeUpdateCost).cost, 2)
        
        let c = makeTree(root: "a", edges: [("a", "x")])
        let dist1 = try editingDistance(from: a, to: c, insertCost: insertCost, removeCost: removeCost, updateCost: smallUpdateCost).cost
        let dist2 = try editingDistance(from: a, to: c, insertCost: noInsertCost, removeCost: removeCost, updateCost: smallUpdateCost).cost
        XCTAssert(dist1 > dist2)
    }
    
    func testDistance() throws {
        let trees = [tree1, tree2, tree3, tree4]
        for(a, b) in product(trees, trees) {
            let ab = try editingDistance(from: a, to: b).cost
            let ba = try editingDistance(from: b, to: a).cost
            XCTAssertEqual(ab, ba)
        }
        
        for((a, b), c) in product(product(trees, trees), trees) {
            let ab = try editingDistance(from: a, to: b).cost
            let bc = try editingDistance(from: b, to: c).cost
            let ac = try editingDistance(from: a, to: c).cost
            XCTAssertTrue(ac <= ab + bc)
        }
    }
    
//    func testRandTree() {
//        let t = randTree(depth: 5, labelLen: 3, width: 2)
//        print(t.jsonString(outputFormatting: [.prettyPrinted, .sortedKeys]))
//    }
    
    func testSymmetry() throws {
        let trees = (0..<3).map { _ in randTree(depth: 5, labelLen: 3, width: 2) }
        for(a, b) in product(trees, trees) {
            let ab = try editingDistance(from: a, to: b).cost
            let ba = try editingDistance(from: b, to: a).cost
//            print(ab, ba)
            XCTAssertEqual(ab, ba)
        }
    }
    
    func testNondegeneracy() throws {
        let trees = (0..<3).map { _ in randTree(depth: 5, labelLen: 3, width: 2) }
        for(a, b) in product(trees, trees) {
            let d = try editingDistance(from: a, to: b).cost
//            print(d, a == b)
            XCTAssertTrue(d == 0 ? a == b : a != b)
        }
    }
    
    func testTriangleInequality() throws {
        let trees1 = (0..<3).map { _ in randTree(depth: 5, labelLen: 3, width: 2) }
        let trees2 = (0..<3).map { _ in randTree(depth: 5, labelLen: 3, width: 2) }
        let trees3 = (0..<3).map { _ in randTree(depth: 5, labelLen: 3, width: 2) }
        for((a, b), c) in product(product(trees1, trees2), trees3) {
            let ab = try editingDistance(from: a, to: b).cost
            let bc = try editingDistance(from: b, to: c).cost
            let ac = try editingDistance(from: a, to: c).cost
//            print(ab, bc, ac)
            XCTAssertTrue(ac < ab + bc)
        }
    }
    
    func testLabelChange() throws {
        for a in (0..<12).lazy.map({ _ in randTree(depth: 5, labelLen: 3, width: 2) }) {
            var b = a
            let node = b.nodes.randomElement()!
            let oldLabel = try! b.nodeData(node)
            let newLabel = "xty"
            try! b.withNodeData(node) { label in
                label = newLabel
            }
            let dist = try editingDistance(from: a, to: b).cost
            let expectedDist: Double = oldLabel == newLabel ? 0 : 1
            XCTAssertEqual(dist, expectedDist)
        }
    }
    
    func testEmpty() throws {
        let t1 = makeTree(root: "", edges: [])
        let t2 = makeTree(root: "a", edges: [])
        let t3 = makeTree(root: "b", edges: [])
        XCTAssertEqual(try editingDistance(from: t1, to: t1).cost, 0)
        XCTAssertEqual(try editingDistance(from: t2, to: t1).cost, 1)
        XCTAssertEqual(try editingDistance(from: t1, to: t3).cost, 1)
    }
    
    func testSimpleLabelChange() throws {
        let a = makeTree(root: "f", edges: [
            ("f", "a"),
                ("a", "h"),
                ("a", "c"),
                    ("c", "l"),
            ("f", "e"),
        ])

        let b = makeTree(root: "f", edges: [
            ("f", "a"),
                ("a", "d"),
                ("a", "r"),
                    ("r", "b"),
            ("f", "e"),
        ])
        XCTAssertEqual(try editingDistance(from: a, to: b).cost, 3)
    }
    
    func testIncorrectBehaviorRegression() throws {
        let a = makeTree(root: "a", edges: [
            ("a", "b"),
                ("b", "x"),
                ("b", "y"),
        ])

        let b = makeTree(root: "a", edges: [
            ("a", "x"),
            ("a", "b"),
                ("b", "y"),
        ])
        XCTAssertEqual(try editingDistance(from: a, to: b).cost, 2)
    }
    
    func testWrongRemoval() throws {
        let a = makeTree(root: "a", edges: [
            ("a", "b"),
            ("a", "c"),
        ])
        let b = makeTree(root: "a", edges: [])
        XCTAssertEqual(try editingDistance(from: a, to: b).cost, 2)
    }
    
    func testInsertAtRoot() throws {
        let a = makeTree(root: "a", edges: [
            ("a", "b"),
            ("a", "c"),
        ])

        let b = makeTree(root: "z", edges: [
            ("z", "a"),
                ("a", "b"),
                ("a", "c"),
        ])
        print(
            try editingDistance(from: a, to: b).ops
                .map({ $0.description })
                .joined(separator: "\n")
        )
    }
    
//    func testOpsAB() throws {
//        func run(_ a: TreeType, _ b: TreeType, _ expectedOps: String? = nil) throws {
//            let ops = try editingDistance(from: a, to: b).ops
//
//            let opsString = ops.map({ $0.description }).joined(separator: "\n")
//
//            if let expectedOps {
//                XCTAssertEqual(opsString, expectedOps)
//            } else {
//                print(a.format, terminator: "\n\n")
//                print(b.format, terminator: "\n\n")
//                print(opsString, terminator: "\n\n")
//            }
//
//            var _nextNodeID = a.nodes.max()! + 1
//            var _nextEdgeID = a.edges.max()! + 1
//
//            func nextNodeID() -> NodeID {
//                defer { _nextNodeID += 1}
//                return _nextNodeID
//            }
//
//            func nextEdgeID() -> EdgeID {
//                defer { _nextEdgeID += 1 }
//                return _nextEdgeID
//            }
//
//            let c = try a.applyEditingOperations(ops, nextNodeID: nextNodeID, nextEdgeID: nextEdgeID, makeEdgeData: ({ Empty() })) { op, t in
//                print(op)
//                print(t.format, terminator: "\n\n")
//            }
//            if expectedOps == nil {
//                print(c.format)
//            }
//            XCTAssertEqual(c.format, b.format)
//        }
//        
////        try run(treeA, treeB)
////        
////        try run(treeA, treeB,
////        """
////        (remove, 3, c)
////        (insert, 1, c)
////        """)
//        
//        try run(treeA, treeC)
//    }
}

fileprivate var tree1: TreeType = {
    makeTree(root: "f", edges: [
        ("f", "d"),
            ("d", "a"),
            ("d", "c"),
                ("c", "b"),
        ("f", "e"),
    ])
}()

fileprivate var tree2: TreeType = {
    makeTree(root: "a", edges: [
        ("a", "c"),
            ("c", "d"),
                ("d", "b"),
                ("d", "e"),
        ("a", "f"),
    ])
}()

fileprivate var tree3: TreeType = {
    makeTree(root: "a", edges: [
        ("a", "d"),
            ("d", "f"),
            ("d", "c"),
                ("c", "b"),
        ("a", "e"),
    ])
}()

fileprivate var tree4: TreeType = {
    makeTree(root: "f", edges: [
        ("f", "d"),
            ("d", "q"),
            ("d", "c"),
                ("c", "b"),
        ("f", "e"),
    ])
}()

fileprivate var tree5: TreeType = {
    makeTree(root: "f", edges: [
        ("f", "c"),
            ("c", "d"),
                ("d", "a"),
                ("d", "b"),
        ("f", "e")
    ])
}()

fileprivate let treeA = tree1
fileprivate let treeB = tree5
fileprivate let treeC = tree2

fileprivate var treeD: TreeType = {
    makeTree(root: "a", edges: [
        ("a", "b"),
        ("a", "c"),
    ])
}()

fileprivate var treeE: TreeType = {
    makeTree(root: "a", edges: [])
}()

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

fileprivate func simpleTrees() -> (TreeType, TreeType) {
    (tree1, tree5)
}

fileprivate func simpleAnnotatedTrees() -> (AnnotatedTree<TreeType>, AnnotatedTree<TreeType>) {
    return (AnnotatedTree(tree1), AnnotatedTree(tree5))
}

fileprivate func makeTree(root: String, edges: [(String, String)]) -> TreeType {
    var gen = IDGen(nextNode: 100, nextEdge: 200)
    return makeTree(root: root, edges: edges, gen: &gen)
}

fileprivate func makeTree(root: String, edges: [(String, String)], gen: inout IDGen) -> TreeType {
    var graph = GraphType(isOrdered: true)
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
