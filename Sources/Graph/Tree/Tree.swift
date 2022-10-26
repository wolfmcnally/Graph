import Foundation

public struct Tree<InnerGraph>: EditableTree, ViewableGraphWrapper
where InnerGraph: EditableGraph
{
    public typealias NodeID = InnerGraph.NodeID
    public typealias EdgeID = InnerGraph.EdgeID
    public typealias NodeData = InnerGraph.NodeData
    public typealias EdgeData = InnerGraph.EdgeData
    
    public let root: NodeID
    public var graph: InnerGraph
    
    public init(graph: InnerGraph, root: NodeID) throws {
        guard try graph.isTree(root: root) else {
            throw GraphError.notATree
        }
        self.graph = graph
        self.root = root
    }
    
    public var data: InnerGraph.GraphData {
        get { graph.data }
        set { graph.data = newValue }
    }
}

// MARK: - EditableTree Implementations

extension Tree
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
