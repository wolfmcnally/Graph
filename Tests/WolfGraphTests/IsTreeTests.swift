import XCTest
import WolfGraph

final class IsTreeTests: XCTestCase {
    func testIsTree() throws {
        typealias G = Graph<String, String, Void, Void>
        
        var g = G()

        func isATree() {
            try! XCTAssertTrue(g.isTree(root: "root"))
        }
        
        func isNotATree(root: String = "root") {
            try! XCTAssertFalse(g.isTree(root: root))
        }

        // Only a root? That's a tree.
        g = try g.newNode("root")
        isATree()

        // Some other unconnected node? Not a tree.
        g = try g.newNode("A")
        isNotATree()
        
        // Connect them? That's a tree.
        g = try g.newEdge("rA", tail: "root", head: "A")
        isATree()
        
        // Add another branch. Still a tree.
        g = try g
            .newNode("B")
            .newEdge("rB", tail: "root", head: "B")
        isATree()
        
        // ...But not if we start with a non-root.
        isNotATree(root: "A")
        
        // Add another level to the tree.
        g = try g
            .newNode("C")
            .newNode("D")
            .newNode("E")
            .newNode("F")
            .newEdge("AC", tail: "A", head: "C")
            .newEdge("AD", tail: "A", head: "D")
            .newEdge("BE", tail: "B", head: "E")
            .newEdge("BF", tail: "B", head: "F")
        isATree()
        
        // Make a copy
        let undo = g
        
        // No cross-edges allowed
        g = try g.newEdge("CE", tail: "C", head: "E")
        isNotATree()
        
        // Restore from backup
        g = undo
        isATree()
        
        // No back-edges allowed
        g = try g.newEdge("Cr", tail: "C", head: "root")
        isNotATree()
        
        // Restore from backup again
        g = undo
        isATree()
        
        // No multiple edges allowed
        g = try g.newEdge("BE2", tail: "B", head: "E")
        isNotATree()
        
        // Back to a real tree
        g = undo
        isATree()
    }
}
