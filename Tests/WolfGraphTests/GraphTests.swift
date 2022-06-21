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
    
    func testTestGraph() {
        let graph = TestGraph.makeTree()
        print(graph.json)
    }
    
    func testDot() throws {
        var graph = TestGraph.makeDAG()
        graph = try graph
            .newNode("Z")
            .newEdge("AZ", tail: "A", head: "Z", data: .init(label: "AZ"))
            .withNodeData("Z")
        {
            $0.label = "Zebra"
            $0.shape = "pentagon"
        }
        .withNodeData("A") {
            $0.color = "red"
        }
        .withNodeData("J") {
            $0.style = "filled"
        }
        .withEdgeData("AZ") {
            $0.label = "Green"
            $0.color = "green"
        }
        .withEdgeData("JA") {
            $0.style = "bold"
        }
        
        print(graph.dotFormat)
    }
}
