import XCTest
import WolfGraph

final class TopologicalSortTests: XCTestCase {
    func testTopologicalSort() throws {
        try XCTAssertEqual(
            TestGraph.makeDAG().topologicalSort(),
            ["D", "E", "C", "A", "K", "G", "I", "B", "F", "J", "H"]
        )

        try XCTAssertThrowsError(
            TestGraph.makeGraph().topologicalSort()
        )
    }

    func testIsDAG() throws {
        try XCTAssertTrue(TestGraph.makeDAG().isDAG())
        try XCTAssertFalse(TestGraph.makeGraph().isDAG())
    }
}
