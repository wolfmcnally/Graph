import Foundation
import WolfGraph

struct TestGraph: EditableGraph, JSONCodable {
    typealias NodeID = String
    typealias EdgeID = String
    typealias NodeData = String
    typealias EdgeData = String

    typealias InnerGraph = Graph<NodeID, EdgeID, NodeData, EdgeData>
    let innerGraph: InnerGraph

    init() {
        innerGraph = InnerGraph()
    }
    
    private init(innerGraph: InnerGraph) {
        self.innerGraph = innerGraph
    }
    
    func copySettingInnerGraph(_ innerGraph: InnerGraph) -> Self {
        Self(innerGraph: innerGraph)
    }

    init(edges: [(String, String, String)]) throws {
        var graph = InnerGraph()
        
        for edge in edges {
            let (label, tail, head) = edge
            if graph.hasNoNode(tail) {
                graph = try graph.newNode(tail, data: tail)
            }
            if graph.hasNoNode(head) {
                graph = try graph.newNode(head, data: head)
            }
            graph = try graph.newEdge(label, tail: tail, head: head, data: label)
        }
        
        self.innerGraph = graph
    }
}

extension TestGraph {
    static func makeDAG() -> Self {
        try! Self(edges: [
            ("AC", "A", "C"),
            ("AD", "A", "D"),
            ("AE", "A", "E"),
            ("BA", "B", "A"),
            ("BC", "B", "C"),
            ("BG", "B", "G"),
            ("CD", "C", "D"),
            ("ED", "E", "D"),
            ("FD", "F", "D"),
            ("FE", "F", "E"),
            ("HJ", "H", "J"),
            ("IC", "I", "C"),
            ("IK", "I", "K"),
            ("JA", "J", "A"),
            ("JE", "J", "E"),
            ("JF", "J", "F"),
            ("GI", "I", "G"),
            ("IB", "B", "I"),
        ])
    }
    
    static func makeGraph() -> Self {
        try! Self(edges: [
            ("AC", "A", "C"),
            ("AD", "A", "D"),
            ("AE", "A", "E"),
            ("BA", "B", "A"),
            ("BC", "B", "C"),
            ("BG", "B", "G"),
            ("CD", "C", "D"),
            ("ED", "E", "D"),
            ("FD", "F", "D"),
            ("FE", "F", "E"),
            ("HJ", "H", "J"),
            ("IC", "I", "C"),
            ("IK", "I", "K"),
            ("JA", "J", "A"),
            ("JE", "J", "E"),
            ("JF", "J", "F"),
            ("GI", "G", "I"), // back edge
            ("IB", "I", "B"), // back edge
        ])
    }
    
    static func makeTree() -> Self {
        try! Self(edges: [
            ("AB", "A", "B"),
            ("AC", "A", "C"),
            ("AD", "A", "D"),
            ("DE", "D", "E"),
            ("DF", "D", "F"),
            ("DG", "D", "G"),
            ("CH", "C", "H"),
            ("BI", "B", "I"),
            ("HJ", "H", "J"),
            ("HK", "H", "K"),
            ("FL", "F", "L"),
            ("EM", "E", "M"),
            ("EN", "E", "N"),
            ("EO", "E", "O"),
        ])
    }
}
