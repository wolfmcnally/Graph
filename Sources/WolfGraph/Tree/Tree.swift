import Foundation

public struct Tree<NodeID, EdgeID, NodeData, EdgeData>: ViewableTree
where NodeID: ElementID, EdgeID: ElementID
{
    public typealias InnerGraph = Graph<NodeID, EdgeID, NodeData, EdgeData>
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

extension Tree: EditableTree {
    public func copySettingInnerGraph(_ innerGraph: InnerGraph) -> Self {
        try! Self(innerGraph: innerGraph, root: root)
    }

    public init(root: NodeID, data: NodeData) {
        self.innerGraph = try! InnerGraph()
            .newNode(root, data: data)
        self.root = root
    }
}

extension Tree where NodeData: DefaultConstructable {
    public init(root: NodeID) {
        self.init(root: root, data: NodeData())
    }
}

extension Tree where NodeData == Void {
    public init(root: NodeID) {
        self.init(root: root, data: ())
    }
}
