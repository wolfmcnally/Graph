import XCTest
import WolfGraph

final class DAGTests: XCTestCase {
    func testDAGCodable() throws {
        let dag = try DAG(graph: TestGraph.makeDAG())
        let json = #"{"edges":{"AC":["A","C","AC"],"AD":["A","D","AD"],"AE":["A","E","AE"],"BA":["B","A","BA"],"BC":["B","C","BC"],"BG":["B","G","BG"],"CD":["C","D","CD"],"ED":["E","D","ED"],"FD":["F","D","FD"],"FE":["F","E","FE"],"GI":["I","G","GI"],"HJ":["H","J","HJ"],"IB":["B","I","IB"],"IC":["I","C","IC"],"IK":["I","K","IK"],"JA":["J","A","JA"],"JE":["J","E","JE"],"JF":["J","F","JF"]},"nodes":{"A":"A","B":"B","C":"C","D":"D","E":"E","F":"F","G":"G","H":"H","I":"I","J":"J","K":"K"}}"#
        XCTAssertEqual(dag.jsonString, json)
    }
    
    func testNotADAG() throws {
        XCTAssertThrowsError(try DAG(graph: TestGraph.makeGraph()))
    }
}
