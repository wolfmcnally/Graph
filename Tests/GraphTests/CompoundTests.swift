import XCTest
import Graph

final class CompoundTests: XCTestCase {
    func testCompoundGraph() throws {
        typealias NodeID = String
        typealias EdgeID = String
        typealias NodeData = String
        typealias EdgeData = String
        typealias TreeGraph = Graph<NodeID, EdgeID, Empty, Empty>
        typealias CompoundTree = Tree<TreeGraph>
        typealias CompoundGraph = Graph<NodeID, EdgeID, NodeData, EdgeData>
        typealias MyCompound = Compound<CompoundGraph, CompoundTree>
        
        let root = "root"
        var treeGraph = TreeGraph()
        try treeGraph.newNode(root)
        let tree = try CompoundTree(graph: treeGraph, root: root)
        let compoundGraph = CompoundGraph()
        var compound = try MyCompound(graph: compoundGraph, tree: tree)
        try compound.newNode("A", parent: "root", edge: "tree-rA")
        try compound.newNode("B", parent: "root", edge: "tree-rB")
        try compound.newNode("C", parent: "root", edge: "tree-rC")
        try compound.newNode("D", parent: "C", edge: "tree-CD")
        try compound.newEdge("AB", tail: "A", head: "B")

        let json = #"{"graph":{"edges":{"AB":["A","B",""]},"nodes":{"A":"","B":"","C":"","D":""}},"tree":{"edges":{"tree-CD":["C","D"],"tree-rA":["root","A"],"tree-rB":["root","B"],"tree-rC":["root","C"]},"nodes":["A","B","C","D","root"],"root":"root"}}"#
        XCTAssertEqual(compound.jsonString, json)
    }
    
    func testCompoundDAG() throws {
        typealias NodeID = TestGraph.NodeID
        typealias EdgeID = TestGraph.EdgeID
        typealias NodeData = TestGraph.NodeData
        typealias EdgeData = TestGraph.EdgeData

        typealias TreeGraph = Graph<NodeID, EdgeID, Empty, Empty>
        typealias CompoundTree = Tree<TreeGraph>
        typealias CompoundDAG = DAG<TestGraph>
        typealias MyCompound = Compound<CompoundDAG, CompoundTree>
        
        let root = "root"
        var treeGraph = TreeGraph()
        try treeGraph.newNode("root")
        var tree = try CompoundTree(graph: treeGraph, root: root)
        let compoundDAG = try CompoundDAG(graph: TestGraph.makeDAG())
        for node in compoundDAG.nodes {
            try tree.newNode(node, parent: "root", edge: "r\(node)")
        }
        let compound = try MyCompound(graph: compoundDAG, tree: tree)
        let json = #"{"graph":{"edges":{"AC":["A","C","AC"],"AD":["A","D","AD"],"AE":["A","E","AE"],"BA":["B","A","BA"],"BC":["B","C","BC"],"BG":["B","G","BG"],"CD":["C","D","CD"],"ED":["E","D","ED"],"FD":["F","D","FD"],"FE":["F","E","FE"],"GI":["I","G","GI"],"HJ":["H","J","HJ"],"IB":["B","I","IB"],"IC":["I","C","IC"],"IK":["I","K","IK"],"JA":["J","A","JA"],"JE":["J","E","JE"],"JF":["J","F","JF"]},"nodes":{"A":"A","B":"B","C":"C","D":"D","E":"E","F":"F","G":"G","H":"H","I":"I","J":"J","K":"K"}},"tree":{"edges":{"rA":["root","A"],"rB":["root","B"],"rC":["root","C"],"rD":["root","D"],"rE":["root","E"],"rF":["root","F"],"rG":["root","G"],"rH":["root","H"],"rI":["root","I"],"rJ":["root","J"],"rK":["root","K"]},"nodes":["A","B","C","D","E","F","G","H","I","J","K","root"],"root":"root"}}"#
        XCTAssertEqual(compound.jsonString, json)
    }
}
