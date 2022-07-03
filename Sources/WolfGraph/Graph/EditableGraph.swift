import Foundation

public protocol EditableGraph: EditableGraphBase {
    mutating func newNode(_ node: NodeID, data: NodeData) throws
}

public protocol EditableGraphWrapper: ViewableGraphWrapper, EditableGraphBaseWrapper where InnerGraph: EditableGraph {
}

public extension EditableGraphWrapper {
    mutating func newNode(_ node: NodeID, data: NodeData) throws {
        try graph.newNode(node, data: data)
    }
}

public extension EditableGraphWrapper where NodeData: DefaultConstructable {
    mutating func newNode(_ node: NodeID) throws {
        try graph.newNode(node, data: NodeData())
    }
}

public extension EditableGraphWrapper where NodeData == Void {
    mutating func newNode(_ node: NodeID) throws {
        try graph.newNode(node, data: ())
    }
}
