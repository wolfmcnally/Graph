import XCTest
import Graph

final class TreeTests: XCTestCase {
    func testIsTree() throws {
        typealias G = Graph<String, String, Empty, Empty>
        
        var g = G()

        func isATree() {
            try! XCTAssertTrue(g.isTree(root: "root"))
        }
        
        func isNotATree(root: String = "root") {
            try! XCTAssertFalse(g.isTree(root: root))
        }

        // Only a root? That's a tree.
        try g.newNode("root")
        isATree()

        // Some other unconnected node? Not a tree.
        try g.newNode("A")
        isNotATree()
        
        // Connect them? That's a tree.
        try g.newEdge("rA", tail: "root", head: "A")
        isATree()
        
        // Add another branch. Still a tree.
        try g.newNode("B")
        try g.newEdge("rB", tail: "root", head: "B")
        isATree()
        
        // ...But not if we start with a non-root.
        isNotATree(root: "A")
        
        // Add another level to the tree.
        try g.newNode("C")
        try g.newNode("D")
        try g.newNode("E")
        try g.newNode("F")
        try g.newEdge("AC", tail: "A", head: "C")
        try g.newEdge("AD", tail: "A", head: "D")
        try g.newEdge("BE", tail: "B", head: "E")
        try g.newEdge("BF", tail: "B", head: "F")
        isATree()
        
        // Make a copy
        let undo = g
        
        // No cross-edges allowed
        try g.newEdge("CE", tail: "C", head: "E")
        isNotATree()
        
        // Restore from backup
        g = undo
        isATree()
        
        // No back-edges allowed
        try g.newEdge("Cr", tail: "C", head: "root")
        isNotATree()
        
        // Restore from backup again
        g = undo
        isATree()
        
        // No multiple edges allowed
        try g.newEdge("BE2", tail: "B", head: "E")
        isNotATree()
        
        // Back to a real tree
        g = undo
        isATree()
    }
    
    func testTreeCodable() throws {
        let t1 = try Tree(graph: TestGraph.makeTree(), root: "A")
        let json = #"{"edges":{"AB":["A","B","AB"],"AC":["A","C","AC"],"AD":["A","D","AD"],"BI":["B","I","BI"],"CH":["C","H","CH"],"DE":["D","E","DE"],"DF":["D","F","DF"],"DG":["D","G","DG"],"EM":["E","M","EM"],"EN":["E","N","EN"],"EO":["E","O","EO"],"FL":["F","L","FL"],"HJ":["H","J","HJ"],"HK":["H","K","HK"]},"nodes":{"A":"A","B":"B","C":"C","D":"D","E":"E","F":"F","G":"G","H":"H","I":"I","J":"J","K":"K","L":"L","M":"M","N":"N","O":"O"},"root":"A"}"#
        XCTAssertEqual(t1.jsonString, json)
        let t2 = try Tree<TestGraph>.fromJSON(json)
        XCTAssertEqual(t1, t2)
        XCTAssertEqual(json, t2.jsonString)
    }
}
