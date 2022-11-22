import Foundation

public protocol EditableGraph2: EditableGraphBase2 {
    mutating func newNode(_ node: NodeID, data: NodeData) throws
}

public protocol EditableGraph: EditableGraph2, EditableGraphBase {
}

public protocol OrderedEditableGraph: EditableGraph2, OrderedEditableGraphBase {
}
