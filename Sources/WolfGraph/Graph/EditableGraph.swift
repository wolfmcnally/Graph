import Foundation

public protocol EditableGraph: EditableGraphBase {
    func newNode(_ node: NodeID, data: NodeData) throws -> Self
}

public extension EditableGraph {
    func newNode(_ node: NodeID, data: NodeData) throws -> Self {
        try copySettingInner(graph: graph.newNode(node, data: data))
    }
}

public extension EditableGraph where NodeData: DefaultConstructable {
    func newNode(_ node: NodeID) throws -> Self {
        try copySettingInner(graph: graph.newNode(node, data: NodeData()))
    }
}

public extension EditableGraph where NodeData == Void {
    func newNode(_ node: NodeID) throws -> Self {
        try copySettingInner(graph: graph.newNode(node, data: ()))
    }
}
