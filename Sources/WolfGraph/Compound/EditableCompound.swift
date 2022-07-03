import Foundation

public protocol EditableCompound: ViewableCompound, EditableGraphBase
where InnerGraph: EditableGraph, InnerTree: EditableTree
{
    mutating func newNode(_ node: NodeID, data: NodeData, parent: NodeID, edge: EdgeID) throws
    mutating func newEdge(_ edge: EdgeID, tail: NodeID, head: NodeID, data: EdgeData) throws
}

public extension EditableCompound
where NodeData: DefaultConstructable
{
    mutating func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID) throws {
        try newNode(node, data: NodeData(), parent: parent, edge: edge)
    }
}

public extension EditableCompound
where NodeData == Void
{
    mutating func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID) throws {
        try newNode(node, data: (), parent: parent, edge: edge)
    }
}
