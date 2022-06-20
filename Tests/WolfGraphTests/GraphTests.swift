import XCTest
import WolfGraph

final class GraphTests: XCTestCase {
    func test1() throws {
        let graph = try Graph<Int, Int, String, String>()
            .newNode(1, "A")
            .newNode(2, "B")
            .newNode(3, "C")
            .newNode(4, "D")
            .newEdge(5, 1, 2, "AB")
            .newEdge(6, 1, 3, "AC")
        XCTAssertEqual(graph.json, #"{"edges":{"5":[1,2,"AB"],"6":[1,3,"AC"]},"nodes":{"1":"A","2":"B","3":"C","4":"D"}}"#)
    }

    func test2() throws {
        let graph = try Graph<Int, Int, Void, Void>()
            .newNode(1)
            .newNode(2)
            .newNode(3)
            .newNode(4)
            .newEdge(5, 1, 2)
            .newEdge(6, 1, 3)
            .newNode(7)
        XCTAssertEqual(graph.json, #"{"edges":{"5":[1,2],"6":[1,3]},"nodes":[4,7]}"#)
    }
}
