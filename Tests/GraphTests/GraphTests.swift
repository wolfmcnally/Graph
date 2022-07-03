import XCTest
import Graph

final class GraphTests: XCTestCase {
    func testCodableData() throws {
        typealias MyGraph = Graph<Int, Int, String, String>
        var graph = MyGraph()
        try graph.newNode(101, data: "A")
        try graph.newNode(102, data: "B")
        try graph.newNode(103, data: "C")
        try graph.newNode(104, data: "D")
        try graph.newEdge(1, tail: 101, head: 102, data: "AB")
        try graph.newEdge(2, tail: 101, head: 103, data: "AC")
        let json = #"{"edges":{"1":[101,102,"AB"],"2":[101,103,"AC"]},"nodes":{"101":"A","102":"B","103":"C","104":"D"}}"#
        XCTAssertEqual(graph.jsonString, json)
        let graph2 = try MyGraph.fromJSON(json)
        XCTAssertEqual(graph, graph2)
        XCTAssertEqual(graph2.jsonString, json)
    }

    func testDefaultData() throws {
        typealias MyGraph = Graph<Int, Int, String, String>
        var graph = MyGraph()
        try graph.newNode(101)
        try graph.newNode(102)
        try graph.newNode(103)
        try graph.newNode(104)
        try graph.newEdge(1, tail: 101, head: 102)
        try graph.newEdge(2, tail: 101, head: 103)
        let json = #"{"edges":{"1":[101,102,""],"2":[101,103,""]},"nodes":{"101":"","102":"","103":"","104":""}}"#
        XCTAssertEqual(graph.jsonString, json)
        let graph2 = try MyGraph.fromJSON(json)
        XCTAssertEqual(graph, graph2)
        XCTAssertEqual(graph2.jsonString, json)
    }

    func testVoidData() throws {
        /// Because the node and edge data types are `Void`, the graph is not `Codable` or `Equatable`
        typealias MyGraph = Graph<Int, Int, Void, Void>
        var graph = MyGraph()
        try graph.newNode(101)
        try graph.newNode(102)
        try graph.newNode(103)
        try graph.newNode(104)
        try graph.newEdge(1, tail: 101, head: 102)
        try graph.newEdge(2, tail: 101, head: 103)
        XCTAssertEqual(graph.nodesCount, 4)
        XCTAssertEqual(graph.edgesCount, 2)
    }

    func testEmptyData() throws {
        typealias MyGraph = Graph<Int, Int, Empty, Empty>
        var graph = MyGraph()
        try graph.newNode(101)
        try graph.newNode(102)
        try graph.newNode(103)
        try graph.newNode(104)
        try graph.newEdge(1, tail: 101, head: 102)
        try graph.newEdge(2, tail: 101, head: 103)
        let json = #"{"edges":{"1":[101,102],"2":[101,103]},"nodes":[101,102,103,104]}"#
        XCTAssertEqual(graph.jsonString, json)
        let graph2 = try MyGraph.fromJSON(json)
        XCTAssertEqual(graph, graph2)
        XCTAssertEqual(graph2.jsonString, json)
    }

    func testTestGraph1() throws {
        var graph = TestGraph()
        try graph.newNode("A")
        try graph.newNode("B")
        try graph.newNode("C")
        try graph.newEdge("AB", tail: "A", head: "B")
        try graph.newEdge("AC", tail: "A", head: "C")
        let json = #"{"edges":{"AB":["A","B",""],"AC":["A","C",""]},"nodes":{"A":"","B":"","C":""}}"#
        XCTAssertEqual(graph.jsonString, json)
    }
    
    func testTestGraph2() {
        let graph = TestGraph.makeTree()
        let json = #"{"edges":{"AB":["A","B","AB"],"AC":["A","C","AC"],"AD":["A","D","AD"],"BI":["B","I","BI"],"CH":["C","H","CH"],"DE":["D","E","DE"],"DF":["D","F","DF"],"DG":["D","G","DG"],"EM":["E","M","EM"],"EN":["E","N","EN"],"EO":["E","O","EO"],"FL":["F","L","FL"],"HJ":["H","J","HJ"],"HK":["H","K","HK"]},"nodes":{"A":"A","B":"B","C":"C","D":"D","E":"E","F":"F","G":"G","H":"H","I":"I","J":"J","K":"K","L":"L","M":"M","N":"N","O":"O"}}"#
        XCTAssertEqual(graph.jsonString, json)
    }
}
