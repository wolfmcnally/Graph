import XCTest
import WolfGraph

final class GraphTests: XCTestCase {
    func test1() throws {
        typealias MyGraph = Graph<Int, Int, String, String>
        let graph = try MyGraph()
            .newNode(101, data: "A")
            .newNode(102, data: "B")
            .newNode(103, data: "C")
            .newNode(104, data: "D")
            .newEdge(1, tail: 101, head: 102, data: "AB")
            .newEdge(2, tail: 101, head: 103, data: "AC")
        let json = #"{"edges":{"1":[101,102,"AB"],"2":[101,103,"AC"]},"nodes":{"101":"A","102":"B","103":"C","104":"D"}}"#
        XCTAssertEqual(graph.json, json)
        let graph2 = try MyGraph(json: json)
        XCTAssertEqual(graph, graph2)
        XCTAssertEqual(graph2.json, json)
    }

    func test2() throws {
        typealias MyGraph = Graph<Int, Int, String, String>
        let graph = try MyGraph()
            .newNode(101)
            .newNode(102)
            .newNode(103)
            .newNode(104)
            .newEdge(1, tail: 101, head: 102)
            .newEdge(2, tail: 101, head: 103)
        let json = #"{"edges":{"1":[101,102,""],"2":[101,103,""]},"nodes":{"101":"","102":"","103":"","104":""}}"#
        XCTAssertEqual(graph.json, json)
        let graph2 = try MyGraph(json: json)
        XCTAssertEqual(graph, graph2)
        XCTAssertEqual(graph2.json, json)
    }
    
    func testTestGraph1() throws {
        let graph = try TestGraph()
            .newNode("A")
            .newNode("B")
            .newNode("C")
            .newEdge("AB", tail: "A", head: "B", data: "")
            .newEdge("AC", tail: "A", head: "C", data: "")
        print(graph.json)
    }
    
    func testTestGraph() {
        let graph = TestGraph.makeTree()
        print(graph.json)
    }
}
