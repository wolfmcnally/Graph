import Foundation
import WolfBase

public protocol EditableTree: ViewableTree where InnerGraph: EditableGraph
{
//    init(root: NodeID, data: NodeData)
    
    func copySettingInnerGraph(_ innerGraph: InnerGraph) -> Self
    
    func withNodeData(_ node: NodeID, transform: (inout NodeData) -> Void) throws -> Self
    func setNodeData(_ node: NodeID, data: NodeData) throws -> Self
    func withEdgeData(_ edge: EdgeID, transform: (inout EdgeData) -> Void) throws -> Self
    func setEdgeData(_ edge: EdgeID, data: EdgeData) throws -> Self

    func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID, nodeData: NodeData, edgeData: EdgeData) throws -> Self
    func removeNodeUngrouping(_ node: NodeID) throws -> Self
    func removeNodeAndChildren(_ node: NodeID) throws -> Self
    func moveNode(_ node: NodeID, newParent: NodeID) throws -> Self
}

public extension EditableTree {
    func withNodeData(_ node: NodeID, transform: (inout NodeData) -> Void) throws -> Self {
        try copySettingInnerGraph(innerGraph.withNodeData(node, transform: transform))
    }
    
    func withEdgeData(_ edge: EdgeID, transform: (inout EdgeData) -> Void) throws -> Self {
        try copySettingInnerGraph(innerGraph.withEdgeData(edge, transform: transform))
    }
    
    func setNodeData(_ node: NodeID, data: NodeData) throws -> Self {
        try withNodeData(node) {
            $0 = data
        }
    }
    
    func setEdgeData(_ edge: EdgeID, data: EdgeData) throws -> Self {
        try withEdgeData(edge) {
            $0 = data
        }
    }
    
    func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID, nodeData: NodeData, edgeData: EdgeData) throws -> Self {
        try copySettingInnerGraph(innerGraph
            .newNode(node, data: nodeData)
            .newEdge(edge, tail: parent, head: node, data: edgeData)
        )
    }

    func removeNodeUngrouping(_ node: NodeID) throws -> Self {
        // Can't remove root
        guard node != root else {
            throw GraphError.notATree
        }
        
        // Promote children to the removed node's parent
        let newParent = try parent(node)!
        let children = try nodeSuccessors(node)
        var copy = self
        for child in children {
            copy = try copy.moveNode(child, newParent: newParent)
        }
        let innerCopy = try copy.innerGraph.removeNode(node)
        
        return copySettingInnerGraph(innerCopy)
    }
    
    func removeNodeAndChildren(_ node: NodeID) throws -> Self {
        // Can't remove root
        guard node != root else {
            throw GraphError.notATree
        }

        // Remove child nodes in reverse-topological sort order (most distant from the target first).
        let removeOrder = try! topologicalSort(roots: [node], rootsOnly: true, isSorted: false)
        var innerCopy = self.innerGraph
        for node in removeOrder {
            innerCopy = try innerCopy.removeNode(node)
        }
        
        return copySettingInnerGraph(innerCopy)
    }

    func moveNode(_ node: NodeID, newParent: NodeID) throws -> Self {
        // Can't move root
        guard node != root else {
            throw GraphError.notATree
        }
        
        let edge = try inEdge(node)!
        guard try canMoveDAGEdge(edge, newTail: newParent, newHead: node) else {
            throw GraphError.notATree
        }
        return try copySettingInnerGraph(innerGraph.moveEdge(edge, newTail: newParent, newHead: node))
    }
}

public extension EditableTree where NodeData: DefaultConstructable {
    func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID, edgeData: EdgeData) throws -> Self {
        try newNode(node, parent: parent, edge: edge, nodeData: NodeData(), edgeData: edgeData)
    }
}

public extension EditableTree where NodeData == Void {
    func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID, edgeData: EdgeData) throws -> Self {
        try newNode(node, parent: parent, edge: edge, nodeData: (), edgeData: edgeData)
    }
}

public extension EditableTree where EdgeData: DefaultConstructable {
    func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID, nodeData: NodeData) throws -> Self {
        try newNode(node, parent: parent, edge: edge, nodeData: nodeData, edgeData: EdgeData())
    }
}

public extension EditableTree where EdgeData == Void {
    func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID, nodeData: NodeData) throws -> Self {
        try newNode(node, parent: parent, edge: edge, nodeData: nodeData, edgeData: ())
    }
}

public extension EditableTree where NodeData: DefaultConstructable, EdgeData: DefaultConstructable {
    func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID) throws -> Self {
        try newNode(node, parent: parent, edge: edge, nodeData: NodeData(), edgeData: EdgeData())
    }
}

public extension EditableTree where NodeData == Void, EdgeData == Void {
    func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID) throws -> Self {
        try newNode(node, parent: parent, edge: edge, nodeData: (), edgeData: ())
    }
}
