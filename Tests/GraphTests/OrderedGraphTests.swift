import XCTest
import Graph
import FUID

extension FUID: ElementID { }

final class OrderedGraphTests: XCTestCase {
    func test1() throws {
        typealias MyGraph = Graph<String, FUID, Void, Void, Void>
        var graph = MyGraph(isOrdered: true)
        
        func format() -> String {
            try! graph.nodeSuccessors("root").map { $0.description }.joined(separator: " ")
        }

        try graph.newNode("root")

        try graph.newNode("red")
        try graph.newNode("orange")
        try graph.newNode("yellow")
        try graph.newNode("green")
        try graph.newNode("blue")
        try graph.newNode("indigo")
        try graph.newNode("violet")

        // Since FUIDs are random, in an unordered (sorted) graph the siblings would be
        // iterated in random order. Because this graph is ordered, they will be iterated
        // in the order they were added.
        try graph.newEdge(FUID(), tail: "root", head: "red")
        try graph.newEdge(FUID(), tail: "root", head: "orange")
        try graph.newEdge(FUID(), tail: "root", head: "yellow")
        try graph.newEdge(FUID(), tail: "root", head: "green")
        try graph.newEdge(FUID(), tail: "root", head: "blue")
        try graph.newEdge(FUID(), tail: "root", head: "indigo")
        try graph.newEdge(FUID(), tail: "root", head: "violet")
        XCTAssertEqual(format(), "red orange yellow green blue indigo violet")
        
        // Insert new edges at the beginning and end of the order.
        try graph.newNode("X")
        try graph.newNode("Y")
        let xEdge = FUID()
        let yEdge = FUID()
        try graph.newEdge(xEdge, tail: "root", at: 0, head: "X")
        try graph.newEdge(yEdge, tail: "root", at: graph.countSuccessors("root"), head: "Y")
        XCTAssertEqual(format(), "X red orange yellow green blue indigo violet Y")
        
        // Move an edge to a different index in the order.
        try graph.moveEdge(xEdge, newTail: "root", at: 3, newHead: "X")
        XCTAssertEqual(format(), "red orange yellow X green blue indigo violet Y")
        try graph.moveEdge(yEdge, to: 0)
        XCTAssertEqual(format(), "Y red orange yellow X green blue indigo violet")
        try graph.moveEdge(yEdge, to: 5)
        XCTAssertEqual(format(), "red orange yellow X green Y blue indigo violet")
        try graph.moveEdgeToBack(xEdge)
        XCTAssertEqual(format(), "red orange yellow green Y blue indigo violet X")
        try graph.moveEdgeToFront(yEdge)
        XCTAssertEqual(format(), "Y red orange yellow green blue indigo violet X")
    }
}
