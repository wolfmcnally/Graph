import Foundation

public protocol EditableGraphBase: ViewableGraph where InnerGraph: EditableGraph {
    func copySettingInner(graph: InnerGraph) -> Self
    
    func withNodeData(_ node: NodeID, transform: (inout NodeData) -> Void) throws -> Self
    func setNodeData(_ node: NodeID, data: NodeData) throws -> Self
    func withEdgeData(_ edge: EdgeID, transform: (inout EdgeData) -> Void) throws -> Self
    func setEdgeData(_ edge: EdgeID, data: EdgeData) throws -> Self
    
    func removeNode(_ node: NodeID) throws -> Self
    func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws -> Self
    func removeEdge(_ edge: EdgeID) throws -> Self
    func removeNodeEdges(_ node: NodeID) throws -> Self
    func moveEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws -> Self
}

public extension EditableGraphBase {
    func withNodeData(_ node: NodeID, transform: (inout NodeData) -> Void) throws -> Self {
        try copySettingInner(graph: graph.withNodeData(node, transform: transform))
    }
    
    func setNodeData(_ node: NodeID, data: NodeData) throws -> Self {
        try withNodeData(node) {
            $0 = data
        }
    }

    func withEdgeData(_ edge: EdgeID, transform: (inout EdgeData) -> Void) throws -> Self {
        try copySettingInner(graph: graph.withEdgeData(edge, transform: transform))
    }
    
    func setEdgeData(_ edge: EdgeID, data: EdgeData) throws -> Self {
        try withEdgeData(edge) {
            $0 = data
        }
    }

    func removeNode(_ node: NodeID) throws -> Self {
        try copySettingInner(graph: graph.removeNode(node))
    }

    func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws -> Self {
        try copySettingInner(graph: graph.newEdge(edge, tail: tail, head: head, data: data))
    }

    func removeEdge(_ edge: EdgeID) throws -> Self {
        try copySettingInner(graph: graph.removeEdge(edge))
    }

    func removeNodeEdges(_ node: NodeID) throws -> Self {
        try copySettingInner(graph: graph.removeNodeEdges(node))
    }
    
    func moveEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws -> Self {
        try copySettingInner(graph: graph.moveEdge(edge, newTail: newTail, newHead: newHead))
    }
}

public extension EditableGraphBase where EdgeData: DefaultConstructable {
    func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID) throws -> Self {
        try newEdge(edge, tail: tail, head: head, data: EdgeData())
    }
}

public extension EditableGraphBase where EdgeData == Void {
    func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID) throws -> Self {
        try newEdge(edge, tail: tail, head: head, data: ())
    }
}
