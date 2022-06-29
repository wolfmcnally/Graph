import XCTest
import WolfGraph

final class CompoundTests: XCTestCase {
    func testCompound1() throws {
        typealias NodeID = Int
        typealias EdgeID = Int
        typealias NodeData = String
        typealias EdgeData = String
        typealias TreeGraph = Graph<NodeID, EdgeID, Empty, Empty>
        typealias CompoundTree = Tree<TreeGraph>
        typealias CompoundGraph = Graph<NodeID, EdgeID, NodeData, EdgeData>
        typealias MyCompound = Compound<CompoundGraph, CompoundTree>
        
        let root = 1
        let treeGraph = try TreeGraph()
            .newNode(root)
        let tree = try CompoundTree(innerGraph: treeGraph, root: root)
        let compoundGraph = CompoundGraph()
        let compound = try MyCompound(graph: compoundGraph, tree: tree)
        print(compound.jsonString)
    }
}
