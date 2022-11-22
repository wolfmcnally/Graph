import Foundation

public struct Tree<InnerGraph>: EditableTree, ViewableGraphWrapper
where InnerGraph: EditableGraph
{
    public typealias NodeID = InnerGraph.NodeID
    public typealias EdgeID = InnerGraph.EdgeID
    public typealias NodeData = InnerGraph.NodeData
    public typealias EdgeData = InnerGraph.EdgeData
    
    public private(set) var root: NodeID!
    public var graph: InnerGraph
    
    public init(graph: InnerGraph, root: NodeID? = nil) throws {
        self.graph = graph
        if let root {
            try setRoot(root)
        }
    }
    
    mutating public func setRoot(_ root: NodeID) throws {
        guard try graph.isTree(root: root) else {
            throw GraphError.notATree
        }
        self.root = root
    }
    
    public var data: InnerGraph.GraphData {
        get { graph.data }
        set { graph.data = newValue }
    }
}

public extension Tree {
    func subtree(root: NodeID) throws -> Self {
        Self(uncheckedInnerGraph: graph, root: root)
    }
    
    mutating func withSubtree<T>(root: NodeID, transform: (inout Self) throws -> T) throws -> T {
        guard graph.hasNode(root) else {
            throw GraphError.notFound
        }
        var tree = Self(uncheckedInnerGraph: graph, root: root)
        let result = try transform(&tree)
        self = tree
        return result
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
