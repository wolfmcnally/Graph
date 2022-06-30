import XCTest
import WolfGraph

final class CompoundTests: XCTestCase {
    func testCompound1() throws {
        typealias NodeID = String
        typealias EdgeID = String
        typealias NodeData = String
        typealias EdgeData = String
        typealias TreeGraph = Graph<NodeID, EdgeID, Empty, Empty>
        typealias CompoundTree = Tree<TreeGraph>
        typealias CompoundGraph = Graph<NodeID, EdgeID, NodeData, EdgeData>
        typealias MyCompound = Compound<CompoundGraph, CompoundTree>
        
        let root = "root"
        let treeGraph = try TreeGraph()
            .newNode(root)
        let tree = try CompoundTree(graph: treeGraph, root: root)
        let compoundGraph = CompoundGraph()
        var compound = try MyCompound(graph: compoundGraph, tree: tree)
        compound = try compound
            .newNode("A", data: "A", parent: "root", edge: "rA")
            .newNode("B", data: "B", parent: "root", edge: "rB")
            .newNode("C", data: "C", parent: "root", edge: "rC")
        print(compound.jsonString)
    }
}
