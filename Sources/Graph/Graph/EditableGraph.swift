import Foundation

public protocol EditableGraph: EditableGraphBase {
    mutating func newNode(_ node: NodeID, data: NodeData) throws
}
