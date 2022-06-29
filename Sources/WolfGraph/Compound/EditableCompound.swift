import Foundation

public protocol EditableCompound: ViewableCompound, EditableGraph
where InnerTree: EditableTree
{
    init(graph: InnerGraph, tree: InnerTree) throws
//    init(graph: InnerGraph, root: NodeID, nextEdgeID: () -> EdgeID) throws
}
