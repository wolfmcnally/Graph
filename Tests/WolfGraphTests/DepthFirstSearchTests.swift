import XCTest
import WolfGraph

final class DepthFirstSearchTests: XCTestCase {
    func testDepthFirstSearch() throws {
        class Visitor: DFSVisitor {
            typealias Graph = TestGraph
            var initNodes: [NodeID] = []
            var startNodes: [NodeID] = []
            var discoveredNodes: [NodeID] = []
            var finishedNodes: [NodeID] = []
            
            var examinedEdges: [EdgeID] = []
            var treeEdges: [EdgeID] = []
            var backEdges: [EdgeID] = []
            var forwardEdges: [EdgeID] = []
            var finishedEdges: [EdgeID] = []
            
            func initNode(_ node: NodeID) -> ()? {
                initNodes.append(node)
                return nil
            }
            
            func startNode(_ node: NodeID) -> ()? {
                startNodes.append(node)
                return nil
            }
            
            func discoverNode(_ node: NodeID) -> ()? {
                discoveredNodes.append(node)
                return nil
            }
            
            func finishNode(_ node: NodeID) -> ()? {
                finishedNodes.append(node)
                return nil
            }
            
            func examineEdge(_ edge: EdgeID) -> ()? {
                examinedEdges.append(edge)
                return nil
            }
            
            func treeEdge(_ edge: EdgeID) -> ()? {
                treeEdges.append(edge)
                return nil
            }
            
            func backEdge(_ edge: EdgeID) -> ()? {
                backEdges.append(edge)
                return nil
            }
            
            func forwardOrCrosseEdge(_ edge: EdgeID) -> ()? {
                forwardEdges.append(edge)
                return nil
            }
            
            func finishEdge(_ edge: EdgeID) -> ()? {
                finishedEdges.append(edge)
                return nil
            }
            
            func finish() -> Void {
            }
        }
        
        let graph = try TestGraph(edges: [
            ("AB", "A", "B"),
            ("AC", "A", "C"),
            ("BD", "B", "D"),
            ("CD", "C", "D"),
            ("DA", "D", "A"),
        ])
        
        let visitor = Visitor()
        try graph.depthFirstSearch(visitor, roots: ["A"])

        XCTAssertEqual(visitor.initNodes, ["A", "B", "C", "D"])
        XCTAssertEqual(visitor.startNodes, ["A"])
        XCTAssertEqual(visitor.discoveredNodes, ["A", "C", "D", "B"])
        XCTAssertEqual(visitor.finishedNodes, ["D", "C", "B", "A"])

        XCTAssertEqual(visitor.examinedEdges, ["AC", "CD", "DA", "AB", "BD"])
        XCTAssertEqual(visitor.treeEdges, ["AC", "CD", "AB"])
        XCTAssertEqual(visitor.backEdges, ["DA"])
        XCTAssertEqual(visitor.forwardEdges, ["BD"])
        XCTAssertEqual(visitor.finishedEdges, ["DA", "CD", "AC", "BD", "AB"])
    }
}
