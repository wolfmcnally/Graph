import Foundation

public protocol EditableCompound: ViewableCompound
where InnerTree: EditableTree
{
    func newNode(_ node: NodeID, data: NodeData, parent: NodeID, edge: EdgeID) throws -> Self
}

public extension EditableCompound
where NodeData: DefaultConstructable
{
    func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID) throws -> Self {
        try newNode(node, data: NodeData(), parent: parent, edge: edge)
    }
}

public extension EditableCompound
where NodeData == Void
{
    func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID) throws -> Self {
        try newNode(node, data: (), parent: parent, edge: edge)
    }
}
