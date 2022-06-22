import Foundation

public protocol EditableGraph: ViewableGraph where InnerGraph: EditableGraph {
    func copySettingInnerGraph(_ innerGraph: InnerGraph) -> Self
    
    func withNodeData(_ node: NodeID, transform: (inout NodeData) -> Void) throws -> Self
    func setNodeData(_ node: NodeID, data: NodeData) throws -> Self
    func withEdgeData(_ edge: EdgeID, transform: (inout EdgeData) -> Void) throws -> Self
    func setEdgeData(_ edge: EdgeID, data: EdgeData) throws -> Self
    func newNode(_ node: NodeID, data: NodeData) throws -> Self
    func removeNode(_ node: NodeID) throws -> Self
    func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws -> Self
    func removeEdge(_ edge: EdgeID) throws -> Self
    func removeNodeEdges(_ node: NodeID) throws -> Self
    func moveEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws -> Self
}

public extension EditableGraph {
    func withNodeData(_ node: NodeID, transform: (inout NodeData) -> Void) throws -> Self {
        try copySettingInnerGraph(innerGraph.withNodeData(node, transform: transform))
    }

    func withEdgeData(_ edge: EdgeID, transform: (inout EdgeData) -> Void) throws -> Self {
        try copySettingInnerGraph(innerGraph.withEdgeData(edge, transform: transform))
    }

    func newNode(_ node: NodeID, data: NodeData) throws -> Self {
        try copySettingInnerGraph(innerGraph.newNode(node, data: data))
    }

    func newNode(_ node: NodeID) throws -> Self {
        try copySettingInnerGraph(innerGraph.newNode(node, data: NodeData()))
    }

    func removeNode(_ node: NodeID) throws -> Self {
        try copySettingInnerGraph(innerGraph.removeNode(node))
    }

    func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws -> Self {
        try copySettingInnerGraph(innerGraph.newEdge(edge, tail: tail, head: head, data: data))
    }

    func removeEdge(_ edge: EdgeID) throws -> Self {
        try copySettingInnerGraph(innerGraph.removeEdge(edge))
    }

    func removeNodeEdges(_ node: NodeID) throws -> Self {
        try copySettingInnerGraph(innerGraph.removeNodeEdges(node))
    }
    
    func moveEdge(_ edge: EdgeID, newTail: NodeID, newHead: NodeID) throws -> Self {
        try copySettingInnerGraph(innerGraph.moveEdge(edge, newTail: newTail, newHead: newHead))
    }
}

public extension EditableGraph {
    func setNodeData(_ node: NodeID, data: NodeData) throws -> Self {
        try withNodeData(node) {
            $0 = data
        }
    }
    
    func setEdgeData(_ edge: EdgeID, data: EdgeData) throws -> Self {
        try withEdgeData(edge) {
            $0 = data
        }
    }

    func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID) throws -> Self {
        try newEdge(edge, tail: tail, head: head, data: EdgeData())
    }
}
