import XCTest
import WolfGraph

final class GraphTests: XCTestCase {
    func testCodableData() throws {
        typealias MyGraph = Graph<Int, Int, String, String>
        let graph = try MyGraph()
            .newNode(101, data: "A")
            .newNode(102, data: "B")
            .newNode(103, data: "C")
            .newNode(104, data: "D")
            .newEdge(1, tail: 101, head: 102, data: "AB")
            .newEdge(2, tail: 101, head: 103, data: "AC")
        let json = #"{"edges":{"1":[101,102,"AB"],"2":[101,103,"AC"]},"nodes":{"101":"A","102":"B","103":"C","104":"D"}}"#
        XCTAssertEqual(graph.jsonString, json)
        let graph2 = try MyGraph.fromJSON(json)
        XCTAssertEqual(graph, graph2)
        XCTAssertEqual(graph2.jsonString, json)
    }

    func testDefaultData() throws {
        typealias MyGraph = Graph<Int, Int, String, String>
        let graph = try MyGraph()
            .newNode(101)
            .newNode(102)
            .newNode(103)
            .newNode(104)
            .newEdge(1, tail: 101, head: 102)
            .newEdge(2, tail: 101, head: 103)
        let json = #"{"edges":{"1":[101,102,""],"2":[101,103,""]},"nodes":{"101":"","102":"","103":"","104":""}}"#
        XCTAssertEqual(graph.jsonString, json)
        let graph2 = try MyGraph.fromJSON(json)
        XCTAssertEqual(graph, graph2)
        XCTAssertEqual(graph2.jsonString, json)
    }

    func testVoidData() throws {
        /// Because the node and edge data types are `Void`, the graph is not `Codable` or `Equatable`
        typealias MyGraph = Graph<Int, Int, Void, Void>
        let graph = try MyGraph()
            .newNode(101)
            .newNode(102)
            .newNode(103)
            .newNode(104)
            .newEdge(1, tail: 101, head: 102)
            .newEdge(2, tail: 101, head: 103)
        XCTAssertEqual(graph.nodesCount, 4)
        XCTAssertEqual(graph.edgesCount, 2)
    }

    func testEmptyData() throws {
        typealias MyGraph = Graph<Int, Int, Empty, Empty>
        let graph = try MyGraph()
            .newNode(101)
            .newNode(102)
            .newNode(103)
            .newNode(104)
            .newEdge(1, tail: 101, head: 102)
            .newEdge(2, tail: 101, head: 103)
        let json = #"{"edges":{"1":[101,102,{}],"2":[101,103,{}]},"nodes":{"101":{},"102":{},"103":{},"104":{}}}"#
        XCTAssertEqual(graph.jsonString, json)
        let graph2 = try MyGraph.fromJSON(json)
        XCTAssertEqual(graph, graph2)
        XCTAssertEqual(graph2.jsonString, json)
    }

    func testTestGraph1() throws {
        let graph = try TestGraph()
            .newNode("A")
            .newNode("B")
            .newNode("C")
            .newEdge("AB", tail: "A", head: "B")
            .newEdge("AC", tail: "A", head: "C")
        let json = #"{"edges":{"AB":["A","B",""],"AC":["A","C",""]},"nodes":{"A":"","B":"","C":""}}"#
        XCTAssertEqual(graph.jsonString, json)
    }
    
    func testTestGraph2() {
        let graph = TestGraph.makeTree()
        let json = #"{"edges":{"AB":["A","B","AB"],"AC":["A","C","AC"],"AD":["A","D","AD"],"BI":["B","I","BI"],"CH":["C","H","CH"],"DE":["D","E","DE"],"DF":["D","F","DF"],"DG":["D","G","DG"],"EM":["E","M","EM"],"EN":["E","N","EN"],"EO":["E","O","EO"],"FL":["F","L","FL"],"HJ":["H","J","HJ"],"HK":["H","K","HK"]},"nodes":{"A":"A","B":"B","C":"C","D":"D","E":"E","F":"F","G":"G","H":"H","I":"I","J":"J","K":"K","L":"L","M":"M","N":"N","O":"O"}}"#
        XCTAssertEqual(graph.jsonString, json)
    }
}
