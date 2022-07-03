import XCTest
import WolfGraph

final class GraphDifferenceTests: XCTestCase {
    func diffTest(from a: TestGraph, to b: TestGraph) throws -> String {
        let aToB = b.difference(from: a)
        let b2 = try a.applyingDifference(aToB)
        XCTAssertEqual(b, b2)
        return aToB.formattedList.trim()
    }
    
    func testTreeToGraph() throws {
        let tree = TestGraph.makeTree()
        let graph = TestGraph.makeGraph()
        let mutations = try diffTest(from: tree, to: graph)
        print(mutations)
        let expectedMutations = """
        .newEdge(AE, A, E, AE)
        .newEdge(BA, B, A, BA)
        .newEdge(BC, B, C, BC)
        .newEdge(BG, B, G, BG)
        .newEdge(CD, C, D, CD)
        .newEdge(ED, E, D, ED)
        .newEdge(FD, F, D, FD)
        .newEdge(FE, F, E, FE)
        .newEdge(GI, G, I, GI)
        .newEdge(IB, I, B, IB)
        .newEdge(IC, I, C, IC)
        .newEdge(IK, I, K, IK)
        .newEdge(JA, J, A, JA)
        .newEdge(JE, J, E, JE)
        .newEdge(JF, J, F, JF)
        .removeEdge(AB)
        .removeEdge(BI)
        .removeEdge(CH)
        .removeEdge(DE)
        .removeEdge(DF)
        .removeEdge(DG)
        .removeEdge(EM)
        .removeEdge(EN)
        .removeEdge(EO)
        .removeEdge(FL)
        .removeEdge(HK)
        .removeNode(L)
        .removeNode(M)
        .removeNode(N)
        .removeNode(O)
        """
        XCTAssertEqual(mutations, expectedMutations)
    }
    
    func testGraphToDAG() throws {
        let graph = TestGraph.makeGraph()
        let dag = TestGraph.makeDAG()
        let mutations = try diffTest(from: graph, to: dag)
        let expectedMutations = """
        .moveEdge(GI, I, G)
        .moveEdge(IB, B, I)
        """
        XCTAssertEqual(mutations, expectedMutations)
    }
    
    func testMutations() throws {
        let graph1 = TestGraph.makeGraph()
        var graph2 = graph1
        try graph2.newNode("Z", data: "Zebra")
        try graph2.setNodeData("A", data: "Alpha")
        try graph2.newEdge("ZA", tail: "Z", head: "A", data: "ZA")
        try graph2.setEdgeData("ZA", data: "Zebra-Alpha")
        try graph2.setEdgeData("AC", data: "AtoC")
        try graph2.moveEdge("GI", newTail: "H", newHead: "G")
        try graph2.setEdgeData("GI", data: "HG")
        try graph2.removeNode("E")
        let mutations = try diffTest(from: graph1, to: graph2)
        let expectedMutations = """
        .newNode(Z, Zebra)
        .setNodeData(A, Alpha)
        .newEdge(ZA, Z, A, Zebra-Alpha)
        .setEdgeData(AC, AtoC)
        .setEdgeData(GI, HG)
        .moveEdge(GI, H, G)
        .removeEdge(AE)
        .removeEdge(ED)
        .removeEdge(FE)
        .removeEdge(JE)
        .removeNode(E)
        """
        XCTAssertEqual(mutations, expectedMutations)
    }
}
