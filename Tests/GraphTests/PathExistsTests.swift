import XCTest
import Graph

final class PathExistsTests: XCTestCase {
    func testPathExists() throws {
        let tests = [
            ("B", "K", true),
            ("B", "A", true),
            ("H", "A", true),
            ("A", "A", true),
            ("I", "B", true),
            ("G", "B", true),
            ("H", "D", true),
            ("D", "H", false),
            ("A", "B", false),
            ("F", "C", false),
            ("J", "I", false),
            ("I", "J", false),
        ]
        let g = TestGraph.makeGraph()
        for test in tests {
            try XCTAssertEqual(g.pathExists(from: test.0, to: test.1), test.2)
        }
    }
    
    func testCanAddDAGEdge() throws {
        let tests = [
            ("H", "I", true),
            ("K", "J", true),
            ("C", "H", false),
            ("E", "B", false),
            ("A", "B", false),
            ("B", "B", false), // Does not allow loops
            ("B", "A", true),  // Does allow multi-edges
        ]
        let g = TestGraph.makeDAG()
        for test in tests {
            try XCTAssertEqual(g.canAddDAGEdge(from: test.0, to: test.1), test.2)
        }
    }
    
    func testCanMoveDAGEdge() throws {
        let tests = [
            // Identity
            ("BA", "B", "A", true),
            
            // Move the head of an edge
            ("JA", "J", "B", true),
            
            // Move the tail of an edge
            ("JA", "H", "A", true),
            
            // Disallow making a cycle
            ("BC", "C", "J", false),
            
            // Allow moving an edge that would have been in a cycle if not moved
            ("JA", "C", "J", true),
            
            // Disallow reversing an edge that makes a cycle
            ("BG", "G", "B", false),
            
            // Reverse an edge without making a cycle
            ("IK", "K", "I", true),
            
            // Does not allow loops
            ("CD", "C", "C", false),
            
            // Does allow multi-edges
            ("AC", "C", "D", true),
        ]
        let g = TestGraph.makeDAG()
        for test in tests {
            try XCTAssertEqual(g.canMoveDAGEdge(test.0, newTail: test.1, newHead: test.2), test.3)
        }
    }
}
