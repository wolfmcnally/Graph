import Foundation

public enum GraphMutation<G: ViewableGraph> {
    public typealias NodeID = G.NodeID
    public typealias EdgeID = G.EdgeID
    public typealias NodeData = G.NodeData
    public typealias EdgeData = G.EdgeData

    case newNode(NodeID, NodeData)
    case setNodeData(NodeID, NodeData)
    case newEdge(EdgeID, NodeID, NodeID, EdgeData)
    case setEdgeData(EdgeID, EdgeData)
    case moveEdge(EdgeID, NodeID, NodeID)
    case removeEdge(EdgeID)
    case removeNode(NodeID)
}

extension GraphMutation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .newNode(let node, let data):
            return ".newNode(\(node), \(data))"
        case .setNodeData(let node, let data):
            return ".setNodeData(\(node), \(data))"
        case .newEdge(let edge, let tail, let head, let data):
            return ".newEdge(\(edge), \(tail), \(head), \(data))"
        case .setEdgeData(let edge, let data):
            return ".setEdgeData(\(edge), \(data))"
        case .moveEdge(let edge, let tail, let head):
            return ".moveEdge(\(edge), \(tail), \(head))"
        case .removeEdge(let edge):
            return ".removeEdge(\(edge))"
        case .removeNode(let node):
            return ".removeNode(\(node))"
        }
    }
}

public struct GraphDifference<G: ViewableGraph> {
    public typealias NodeID = G.NodeID
    public typealias EdgeID = G.EdgeID
    public typealias NodeData = G.NodeData
    public typealias EdgeData = G.EdgeData
    
    // Mutations are in order of application. Application must be atomic:
    // the graph's invariants (e.g., Tree, DAG, no multi-edges, etc.) may not hold
    // until all the changes are applied. The order of application does guarantee that
    // exiting nodes will have no remaining incident edges when they are deleted.
    public let mutations: [GraphMutation<G>]
}

extension GraphDifference: CustomStringConvertible {
    public var description: String {
        "\(mutations)"
    }
}

extension GraphDifference {
    public var formattedList: String {
        mutations.reduce(into: []) { result, mutation in
            result.append(mutation.description)
        }.joined(separator: "\n")
    }
}

public extension ViewableGraph {
    /// Returns the difference needed to produce this graph from the given graph.
    func difference<G>(from other: G) -> GraphDifference<G>
    where G: ViewableGraph,
          NodeID == G.NodeID, EdgeID == G.EdgeID,
          NodeData == G.NodeData, EdgeData == G.EdgeData,
          NodeData: Equatable, EdgeData: Equatable
    {
        let startNodes = Set(other.nodes)
        let endNodes = Set(nodes)
        
        let enteringNodes: [NodeID: NodeData] = endNodes.subtracting(startNodes).reduce(into: .init()) { result, node in
            result[node] = try! nodeData(node)
        }
        let exitingNodes = startNodes.subtracting(endNodes)
        let updatingNodes: [NodeID: NodeData] = startNodes.intersection(endNodes).reduce(into: .init()) { result, node in
            let selfData = try! nodeData(node)
            let otherData = try! other.nodeData(node)
            if selfData != otherData {
                result[node] = selfData
            }
        }
        
        let startEdges = Set(other.edges)
        let endEdges = Set(edges)
        
        let enteringEdges: [EdgeID: (NodeID, NodeID, EdgeData)] = endEdges.subtracting(startEdges).reduce(into: .init()) { result, edge in
            result[edge] = try! (edgeTail(edge), edgeHead(edge), edgeData(edge))
        }
        let exitingEdges = startEdges.subtracting(endEdges)
        let updatableEdges = startEdges.intersection(endEdges)
        let updatingEdges: [EdgeID: EdgeData] = updatableEdges.reduce(into: .init()) { result, edge in
            let selfData = try! edgeData(edge)
            let otherData = try! other.edgeData(edge)
            if selfData != otherData {
                result[edge] = selfData
            }
        }
        let movingEdges: [EdgeID: (NodeID, NodeID)] = updatableEdges.reduce(into: .init()) { result, edge in
            let selfEnds = try! edgeEnds(edge)
            let otherEnds = try! other.edgeEnds(edge)
            if selfEnds != otherEnds {
                result[edge] = selfEnds
            }
        }
        
        var mutations: [GraphMutation<G>] = []
        
        for (node, data) in enteringNodes.sorted(by: { $0.0 < $1.0 }) {
            mutations.append(.newNode(node, data))
        }
        
        for (node, data) in updatingNodes.sorted(by: { $0.0 < $1.0 }) {
            mutations.append(.setNodeData(node, data))
        }
        
        for (edge, (tail, head, data)) in enteringEdges.sorted(by: { $0.0 < $1.0 }) {
            mutations.append(.newEdge(edge, tail, head, data))
        }
        
        for (edge, data) in updatingEdges.sorted(by: { $0.0 < $1.0 }) {
            mutations.append(.setEdgeData(edge, data))
        }
        
        for (edge, (tail, head)) in movingEdges.sorted(by: { $0.0 < $1.0 }) {
            mutations.append(.moveEdge(edge, tail, head))
        }
        
        for edge in exitingEdges.sorted() {
            mutations.append(.removeEdge(edge))
        }
        
        for node in exitingNodes.sorted() {
            mutations.append(.removeNode(node))
        }

        return GraphDifference(mutations: mutations)
    }
}

public extension EditableGraph {
    mutating func applyMutation<G>(_ mutation: GraphMutation<G>) throws
    where G: ViewableGraph,
          NodeID == G.NodeID, EdgeID == G.EdgeID,
          NodeData == G.NodeData, EdgeData == G.EdgeData
    {
        switch mutation {
        case .newNode(let node, let data):
            try newNode(node, data: data)
        case .setNodeData(let node, let data):
            try setNodeData(node, data: data)
        case .newEdge(let edge, let tail, let head, let data):
            try newEdge(edge, tail: tail, head: head, data: data)
        case .setEdgeData(let edge, let data):
            try setEdgeData(edge, data: data)
        case .moveEdge(let edge, let tail, let head):
            try moveEdge(edge, newTail: tail, newHead: head)
        case .removeEdge(let edge):
            try removeEdge(edge)
        case .removeNode(let node):
            try removeNode(node)
        }
    }
    
    mutating func applyDifference<G>(_ diff: GraphDifference<G>) throws
    where G: ViewableGraph,
          NodeID == G.NodeID, EdgeID == G.EdgeID,
          NodeData == G.NodeData, EdgeData == G.EdgeData
    {
        for mutation in diff.mutations {
            try applyMutation(mutation)
        }
    }

    func applyingDifference<G>(_ diff: GraphDifference<G>) throws -> Self
    where G: ViewableGraph,
          NodeID == G.NodeID, EdgeID == G.EdgeID,
          NodeData == G.NodeData, EdgeData == G.EdgeData
    {
        var copy = self
        try copy.applyDifference(diff)
        return copy
    }
}
