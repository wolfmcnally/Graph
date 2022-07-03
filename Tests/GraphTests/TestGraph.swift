import Foundation
import Graph

struct TestGraph: EditableGraph, EditableGraphWrapper, Codable, Equatable {
    typealias NodeID = String
    typealias EdgeID = String
    typealias NodeData = String
    typealias EdgeData = String

    typealias InnerGraph = Graph<NodeID, EdgeID, NodeData, EdgeData>
    var graph: InnerGraph

    init() {
        graph = InnerGraph()
    }
    
    init(graph: InnerGraph) {
        self.graph = graph
    }

    init(edges: [(String, String, String)]) throws {
        var graph = InnerGraph()
        
        for edge in edges {
            let (label, tail, head) = edge
            if graph.hasNoNode(tail) {
                try graph.newNode(tail, data: tail)
            }
            if graph.hasNoNode(head) {
                try graph.newNode(head, data: head)
            }
            try graph.newEdge(label, tail: tail, head: head, data: label)
        }
        
        self.graph = graph
    }
}

extension TestGraph {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(graph)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.graph = try container.decode(InnerGraph.self)
    }
}

extension TestGraph {
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
    
    // http://magjac.com/graphviz-visual-editor/
    /*
     digraph G {
         A [label="A"]
         B [label="B"]
         C [label="C"]
         D [label="D"]
         E [label="E"]
         F [label="F"]
         G [label="G"]
         H [label="H"]
         I [label="I"]
         J [label="J"]
         K [label="K"]
         A -> C [label="AC"]
         A -> D [label="AD"]
         A -> E [label="AE"]
         B -> A [label="BA"]
         B -> C [label="BC"]
         B -> G [label="BG"]
         C -> D [label="CD"]
         E -> D [label="ED"]
         F -> D [label="FD"]
         F -> E [label="FE"]
         G -> I [label="GI"]
         H -> J [label="HJ"]
         I -> B [label="IB"]
         I -> C [label="IC"]
         I -> K [label="IK"]
         J -> A [label="JA"]
         J -> E [label="JE"]
         J -> F [label="JF"]
     }
     */
    
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
    
    // http://magjac.com/graphviz-visual-editor/
    /*
     digraph G {
         A [label="A"]
         B [label="B"]
         C [label="C"]
         D [label="D"]
         E [label="E"]
         F [label="F"]
         G [label="G"]
         H [label="H"]
         I [label="I"]
         J [label="J"]
         K [label="K"]
         A -> C [label="AC"]
         A -> D [label="AD"]
         A -> E [label="AE"]
         B -> A [label="BA"]
         B -> C [label="BC"]
         B -> G [label="BG"]
         C -> D [label="CD"]
         E -> D [label="ED"]
         F -> D [label="FD"]
         F -> E [label="FE"]
         I -> G [label="GI"]
         H -> J [label="HJ"]
         B -> I [label="IB"]
         I -> C [label="IC"]
         I -> K [label="IK"]
         J -> A [label="JA"]
         J -> E [label="JE"]
         J -> F [label="JF"]
     }
     */
    
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

    // http://magjac.com/graphviz-visual-editor/
    /*
     digraph G {
         A [label="A"]
         B [label="B"]
         C [label="C"]
         D [label="D"]
         E [label="E"]
         F [label="F"]
         G [label="G"]
         H [label="H"]
         I [label="I"]
         J [label="J"]
         K [label="K"]
         L [label="L"]
         M [label="M"]
         N [label="N"]
         O [label="O"]
         A -> B [label="AB"]
         A -> C [label="AC"]
         A -> D [label="AD"]
         B -> I [label="BI"]
         C -> H [label="CH"]
         D -> E [label="DE"]
         D -> F [label="DF"]
         D -> G [label="DG"]
         E -> M [label="EM"]
         E -> N [label="EN"]
         E -> O [label="EO"]
         F -> L [label="FL"]
         H -> J [label="HJ"]
         H -> K [label="HK"]
     }
     */
}
