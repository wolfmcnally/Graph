import Foundation

public protocol EditableCompound: ViewableCompound
where InnerTree: EditableTree
{
    func newNode(_ node: NodeID, data: NodeData, parent: NodeID, edge: EdgeID) throws -> Self
}
