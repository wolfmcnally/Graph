import Foundation

public struct Tree<InnerGraph>: ViewableTree
where InnerGraph: ViewableGraph
{
    public typealias NodeID = InnerGraph.NodeID
    public typealias EdgeID = InnerGraph.EdgeID
    public typealias NodeData = InnerGraph.NodeData
    public typealias EdgeData = InnerGraph.EdgeData
    
    public let root: NodeID
    public let graph: InnerGraph
    
    public init(graph: InnerGraph, root: NodeID) throws {
        guard try graph.isTree(root: root) else {
            throw GraphError.notATree
        }
        self.graph = graph
        self.root = root
    }
}

extension Tree: EditableTree
where InnerGraph: EditableGraph
{
    init(uncheckedInnerGraph: InnerGraph, root: NodeID) {
        self.graph = uncheckedInnerGraph
        self.root = root
    }
    
    public func copySettingInner(graph: InnerGraph) -> Self {
        Self(uncheckedInnerGraph: graph, root: root)
    }
}

extension Tree: Equatable where InnerGraph: Equatable {
}
