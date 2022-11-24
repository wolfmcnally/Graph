import XCTest
import Graph
import FUID

fileprivate typealias GraphType = Graph<String, FUID, Void, Void, Void>
fileprivate typealias TreeType = Tree<GraphType>
fileprivate typealias NodeID = TreeType.NodeID
fileprivate typealias EdgeID = TreeType.EdgeID
fileprivate typealias NodeData = TreeType.NodeData

final class OrderedTreeTests: XCTestCase {
    func test1() throws {
        typealias MyGraph = Graph<String, FUID, Void, Void, Void>
        var graph = MyGraph(isOrdered: true)
        try graph.newNode("ROOT")
        var tree = try Tree(graph: graph, root: "ROOT")
        try tree.newNode("a", parent: "ROOT", edge: FUID())
        try tree.newNode("b", parent: "a", edge: FUID())
        try tree.newNode("c", parent: "a", edge: FUID())
        try tree.newNode("d", parent: "ROOT", edge: FUID())
        try tree.newNode("e", parent: "d", edge: FUID())
        try tree.newNode("f", parent: "d", edge: FUID())
        try tree.newNode("g", parent: "ROOT", edge: FUID())
        try tree.newNode("h", parent: "g", edge: FUID())
        try tree.newNode("i", parent: "g", edge: FUID())
        XCTAssertEqual(tree.format,
        """
        ROOT
          a
            b
            c
          d
            e
            f
          g
            h
            i
        """)
        
        try tree.insertNode("X", at: "d", edge: FUID())
        XCTAssertEqual(tree.format,
        """
        ROOT
          a
            b
            c
          X
            d
              e
              f
          g
            h
            i
        """)
        
        try tree.insertNode("Y", at: "ROOT", edge: FUID())
        XCTAssertEqual(tree.format,
        """
        Y
          ROOT
            a
              b
              c
            X
              d
                e
                f
            g
              h
              i
        """)
        
        try tree.removeNodeUngrouping("X")
        XCTAssertEqual(tree.format,
        """
        Y
          ROOT
            a
              b
              c
            d
              e
              f
            g
              h
              i
        """)
        
        try tree.removeNodeUngrouping("Y")
        XCTAssertEqual(tree.format,
        """
        ROOT
          a
            b
            c
          d
            e
            f
          g
            h
            i
        """)
    }
}

extension TreeType {
    var format: String {
        var result: [String] = []
        format(level: 0, node: root, result: &result)
        return result.joined(separator: "\n")
    }
    
    private func format(level: Int, node: NodeID, result: inout [String]) {
        let indent = String(repeating: " ", count: level * 2)
        result.append(indent + node)
        for child in try! children(node) {
            format(level: level + 1, node: child, result: &result)
        }
    }
}
