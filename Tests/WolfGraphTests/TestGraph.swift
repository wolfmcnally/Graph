import Foundation
import WolfGraph

struct TestGraph {
    typealias NodeID = String
    typealias EdgeID = String
    typealias NodeData = Attributes
    typealias EdgeData = Attributes
    
    struct Attributes: ElementData {
        var attrs: [String: String] = [:]
        
        init() { }
        
        init(label: String) {
            attrs["label"] = label
        }
        
        var label: String? {
            get {
                attrs["label"]
            }
            
            set {
                attrs["label"] = newValue
            }
        }
        
        var color: String? {
            get {
                attrs["color"]
            }
            
            set {
                attrs["color"] = newValue
            }
        }
        
        var style: String? {
            get {
                attrs["style"]
            }
            
            set {
                attrs["style"] = newValue
            }
        }
        
        var shape: String? {
            get {
                attrs["shape"]
            }
            
            set {
                attrs["shape"] = newValue
            }
        }

        enum CodingKeys: CodingKey {
            case label
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(label, forKey: .label)
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            var result: [String: String] = [:]
            
            if let label = try container.decodeIfPresent(String.self, forKey: .label) {
                result["label"] = label
            }
            
            self.attrs = result
        }
    }
    
    typealias GraphType = Graph<NodeID, EdgeID, NodeData, EdgeData>
    let graph: GraphType
    
    init(_ graph: GraphType) {
        self.graph = graph
    }
    
    init(edges: [(String, String, String)]) throws {
        var graph = GraphType()
        
        for edge in edges {
            let (label, tail, head) = edge
            if graph.hasNoNode(tail) {
                graph = try graph.newNode(tail, data: .init(label: tail))
            }
            if graph.hasNoNode(head) {
                graph = try graph.newNode(head, data: .init(label: head))
            }
            graph = try graph.newEdge(label, tail: tail, head: head, data: .init(label: label))
        }
        
        self.graph = graph
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

extension TestGraph {
    var json: String {
        graph.json
    }
}

extension TestGraph: ViewableGraph {
    var isEmpty: Bool {
        graph.isEmpty
    }
    
    var nodesCount: Int {
        graph.nodesCount
    }
    
    var edgesCount: Int {
        graph.edgesCount
    }
    
    var nodes: [String] {
        graph.nodes
    }
    
    var edges: [String] {
        graph.edges
    }
    
    func hasNode(_ nodeID: String) -> Bool {
        graph.hasNode(nodeID)
    }
    
    func hasNoNode(_ nodeID: String) -> Bool {
        graph.hasNoNode(nodeID)
    }
    
    func hasEdge(_ edgeID: String) -> Bool {
        graph.hasEdge(edgeID)
    }
    
    func hasNoEdge(_ edgeID: String) -> Bool {
        graph.hasNoEdge(edgeID)
    }
    
    func nodeData(_ nodeID: String) throws -> Attributes {
        try graph.nodeData(nodeID)
    }
    
    func edgeData(_ edgeID: String) throws -> Attributes {
        try graph.edgeData(edgeID)
    }
    
    func nodeOutEdges(_ nodeID: String) throws -> [String] {
        try graph.nodeOutEdges(nodeID)
    }
    
    func nodeInEdges(_ nodeID: String) throws -> [String] {
        try graph.nodeInEdges(nodeID)
    }
    
    func nodeEdges(_ nodeID: String) throws -> [String] {
        try graph.nodeEdges(nodeID)
    }
    
    func nodeSuccessors(_ nodeID: String) throws -> [String] {
        try graph.nodeSuccessors(nodeID)
    }
    
    func nodePredecessors(_ nodeID: String) throws -> [String] {
        try graph.nodePredecessors(nodeID)
    }
    
    func nodeNeighbors(_ nodeID: String) throws -> [String] {
        try graph.nodeNeighbors(nodeID)
    }
    
    func edgeHead(_ edgeID: String) throws -> String {
        try graph.edgeHead(edgeID)
    }
    
    func edgeTail(_ edgeID: String) throws -> String {
        try graph.edgeTail(edgeID)
    }
}

extension TestGraph: EditableGraph {
    func withNodeData(_ nodeID: String, transform: (inout Attributes) -> Void) throws -> Self {
        try TestGraph(graph.withNodeData(nodeID, transform: transform))
    }
    
    func setNodeData(_ nodeID: String, data: Attributes) throws -> Self {
        try TestGraph(graph.setNodeData(nodeID, data: data))
    }
    
    func withEdgeData(_ edgeID: String, transform: (inout Attributes) -> Void) throws -> Self {
        try TestGraph(graph.withEdgeData(edgeID, transform: transform))
    }
    
    func setEdgeData(_ edgeID: String, data: Attributes) throws -> Self {
        try TestGraph(graph.setEdgeData(edgeID, data: data))
    }
    
    func newNode(_ nodeID: String, data: Attributes) throws -> Self {
        try TestGraph(graph.newNode(nodeID, data: data))
    }
    
    func newNode(_ nodeID: String) throws -> Self {
        try TestGraph(graph.newNode(nodeID))
    }
    
    func removeNode(_ nodeID: String) throws -> Self {
        try TestGraph(graph.removeNode(nodeID))
    }
    
    func newEdge(_ edgeID: String, tail: String, head: String, data: Attributes) throws -> Self {
        try TestGraph(graph.newEdge(edgeID, tail: tail, head: head, data: data))
    }
    
    func newEdge(_ edgeID: String, tail: String, head: String) throws -> Self {
        try TestGraph(graph.newEdge(edgeID, tail: tail, head: head))
    }
    
    func removeEdge(_ edgeID: String) throws -> Self {
        try TestGraph(graph.removeEdge(edgeID))
    }
    
    func removeNodeEdges(_ nodeID: String) throws -> Self {
        try TestGraph(graph.removeNodeEdges(nodeID))
    }
    
    func moveEdge(_ edgeID: String, newTail: String, newHead: String) throws -> Self {
        try TestGraph(graph.moveEdge(edgeID, newTail: newTail, newHead: newHead))
    }
}

extension TestGraph: DotEncodable {
    func nodeLabel(_ node: NodeID) -> String? {
        try! nodeData(node).label
    }
    
    func nodeColor(_ node: NodeID) -> String? {
        try! nodeData(node).color
    }
    
    func nodeStyle(_ node: NodeID) -> String? {
        try! nodeData(node).style
    }
    
    func nodeShape(_ node: NodeID) -> String? {
        try! nodeData(node).shape
    }

    
    func edgeLabel(_ edge: EdgeID) -> String? {
        try! edgeData(edge).label
    }
    
    func edgeColor(_ edge: EdgeID) -> String? {
        try! edgeData(edge).color
    }
    
    func edgeStyle(_ edge: EdgeID) -> String? {
        try! edgeData(edge).style
    }
}
