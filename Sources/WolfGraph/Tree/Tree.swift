import Foundation

public struct Tree<TreeInnerGraph>: ViewableTree
where TreeInnerGraph: ViewableGraph
{
    public typealias NodeID = TreeInnerGraph.NodeID
    public typealias EdgeID = TreeInnerGraph.EdgeID
    public typealias NodeData = TreeInnerGraph.NodeData
    public typealias EdgeData = TreeInnerGraph.EdgeData
    
    public let root: NodeID
    public let innerGraph: TreeInnerGraph
    
    public init(innerGraph: TreeInnerGraph, root: NodeID) throws {
        guard try innerGraph.isTree(root: root) else {
            throw GraphError.notATree
        }
        self.innerGraph = innerGraph
        self.root = root
    }
}

extension Tree: EditableTree where TreeInnerGraph: EditableGraph {
    init(uncheckedInnerGraph: TreeInnerGraph, root: NodeID) {
        self.innerGraph = uncheckedInnerGraph
        self.root = root
    }
    
    public func copySettingInnerGraph(_ innerGraph: TreeInnerGraph) -> Self {
        Self(uncheckedInnerGraph: innerGraph, root: root)
    }

    public init(root: NodeID, data: NodeData) {
        self.innerGraph = try! TreeInnerGraph()
            .newNode(root, data: data)
        self.root = root
    }
}

extension Tree where TreeInnerGraph: EditableGraph, NodeData: DefaultConstructable {
    public init(root: NodeID) {
        self.init(root: root, data: NodeData())
    }
}

extension Tree where TreeInnerGraph: EditableGraph, NodeData == Void {
    public init(root: NodeID) {
        self.init(root: root, data: ())
    }
}

extension Tree: Equatable where TreeInnerGraph: Equatable {
}
