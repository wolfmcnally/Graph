import Foundation

public struct Tree<InnerGraph>: ViewableTree
where InnerGraph: ViewableGraph
{
    public typealias NodeID = InnerGraph.NodeID
    public typealias EdgeID = InnerGraph.EdgeID
    public typealias NodeData = InnerGraph.NodeData
    public typealias EdgeData = InnerGraph.EdgeData
    
    public let root: NodeID
    public let innerGraph: InnerGraph
    
    public init(innerGraph: InnerGraph, root: NodeID) throws {
        guard try innerGraph.isTree(root: root) else {
            throw GraphError.notATree
        }
        self.innerGraph = innerGraph
        self.root = root
    }
}

extension Tree: EditableTree
where InnerGraph: EditableGraph
{
    init(uncheckedInnerGraph: InnerGraph, root: NodeID) {
        self.innerGraph = uncheckedInnerGraph
        self.root = root
    }
    
    public func copySettingInnerGraph(_ innerGraph: InnerGraph) -> Self {
        Self(uncheckedInnerGraph: innerGraph, root: root)
    }

    public init(root: NodeID, data: NodeData) {
        self.innerGraph = try! InnerGraph()
            .newNode(root, data: data)
        self.root = root
    }
}

extension Tree where InnerGraph: EditableGraph, NodeData: DefaultConstructable {
    public init(root: NodeID) {
        self.init(root: root, data: NodeData())
    }
}

extension Tree where InnerGraph: EditableGraph, NodeData == Void {
    public init(root: NodeID) {
        self.init(root: root, data: ())
    }
}

extension Tree: Equatable where InnerGraph: Equatable {
}
