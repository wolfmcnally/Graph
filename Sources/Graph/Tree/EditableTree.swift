import Foundation
import WolfBase

public protocol EditableTree: ViewableTree
where NodeID == InnerGraph.NodeID, EdgeID == InnerGraph.EdgeID,
      NodeData == InnerGraph.NodeData, EdgeData == InnerGraph.EdgeData
{
    associatedtype InnerGraph: EditableGraph

    var graph: InnerGraph { get set }
    
    mutating func setRoot(_ root: NodeID) throws

    mutating func withNodeData<T>(_ node: NodeID, transform: (inout NodeData) throws -> T) throws -> T
    mutating func setNodeData(_ node: NodeID, data: NodeData) throws
    mutating func withEdgeData<T>(_ edge: EdgeID, transform: (inout EdgeData) throws -> T) throws -> T
    mutating func setEdgeData(_ edge: EdgeID, data: EdgeData) throws

    mutating func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID, nodeData: NodeData, edgeData: EdgeData) throws
    mutating func removeNodeUngrouping(_ node: NodeID) throws
    mutating func removeNodeAndChildren(_ node: NodeID) throws
    mutating func moveNode(_ node: NodeID, newParent: NodeID) throws
    
    mutating func withSubtree<T>(root: NodeID, transform: (inout Self) throws -> T) throws -> T
}

public extension EditableTree {
    @discardableResult
    mutating func withNodeData<T>(_ node: NodeID, transform: (inout NodeData) throws -> T) throws -> T {
        try graph.withNodeData(node, transform: transform)
    }
    
    @discardableResult
    mutating func withEdgeData<T>(_ edge: EdgeID, transform: (inout EdgeData) throws -> T) throws -> T {
        try graph.withEdgeData(edge, transform: transform)
    }
    
    mutating func setNodeData(_ node: NodeID, data: NodeData) throws {
        try withNodeData(node) {
            $0 = data
        }
    }
    
    mutating func setEdgeData(_ edge: EdgeID, data: EdgeData) throws {
        try withEdgeData(edge) {
            $0 = data
        }
    }
    
    mutating func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID, nodeData: NodeData, edgeData: EdgeData) throws {
        try graph.newNode(node, data: nodeData)
        try graph.newEdge(edge, tail: parent, head: node, data: edgeData)
    }
    
    mutating func insertNode(_ node: NodeID, at existingNode: NodeID, edge: EdgeID, nodeData: NodeData, edgeData: EdgeData) throws {
        if existingNode == root {
            try graph.newNode(node, data: nodeData)
            try graph.newEdge(edge, tail: node, head: root, data: edgeData)
            try setRoot(node)
        } else {
            let parent = try parent(existingNode)!
            try newNode(node, parent: parent, edge: edge, nodeData: nodeData, edgeData: edgeData)
            try moveNode(existingNode, newParent: node)
        }
    }

    mutating func removeNodeUngrouping(_ node: NodeID) throws {
        // Can't remove root
        guard node != root else {
            throw GraphError.notATree
        }
        
        // Promote children to the removed node's parent
        let newParent = try parent(node)!
        let children = try nodeSuccessors(node)
        for child in children {
            try moveNode(child, newParent: newParent)
        }
        try graph.removeNode(node)
    }
    
    mutating func removeNodeAndChildren(_ node: NodeID) throws {
        // Can't remove root
        guard node != root else {
            throw GraphError.notATree
        }

        // Remove child nodes in reverse-topological sort order (most distant from the target first).
        let removeOrder = try! topologicalSort(roots: [node], rootsOnly: true)
        for node in removeOrder {
            try graph.removeNode(node)
        }
    }

    mutating func moveNode(_ node: NodeID, newParent: NodeID) throws {
        // Can't move root
        guard node != root else {
            throw GraphError.notATree
        }
        
        let edge = try inEdge(node)!
        guard try graph.canMoveDAGEdge(edge, newTail: newParent, newHead: node) else {
            throw GraphError.notATree
        }
        return try graph.moveEdge(edge, newTail: newParent, newHead: node)
    }
}

public extension EditableTree where NodeData: DefaultConstructable {
    mutating func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID, edgeData: EdgeData) throws {
        try newNode(node, parent: parent, edge: edge, nodeData: NodeData(), edgeData: edgeData)
    }
    
    mutating func insertNode(_ node: NodeID, at existingNode: NodeID, edge: EdgeID, edgeData: EdgeData) throws {
        try insertNode(node, at: existingNode, edge: edge, nodeData: NodeData(), edgeData: edgeData)
    }
}

public extension EditableTree where NodeData == Void {
    mutating func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID, edgeData: EdgeData) throws {
        try newNode(node, parent: parent, edge: edge, nodeData: (), edgeData: edgeData)
    }
    
    mutating func insertNode(_ node: NodeID, at existingNode: NodeID, edge: EdgeID, edgeData: EdgeData) throws {
        try insertNode(node, at: existingNode, edge: edge, nodeData: (), edgeData: edgeData)
    }
}

public extension EditableTree where EdgeData: DefaultConstructable {
    mutating func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID, nodeData: NodeData) throws {
        try newNode(node, parent: parent, edge: edge, nodeData: nodeData, edgeData: EdgeData())
    }
    
    mutating func insertNode(_ node: NodeID, at existingNode: NodeID, edge: EdgeID, nodeData: NodeData) throws {
        try insertNode(node, at: existingNode, edge: edge, nodeData: nodeData, edgeData: EdgeData())
    }
}

public extension EditableTree where EdgeData == Void {
    mutating func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID, nodeData: NodeData) throws {
        try newNode(node, parent: parent, edge: edge, nodeData: nodeData, edgeData: ())
    }
    
    mutating func insertNode(_ node: NodeID, at existingNode: NodeID, edge: EdgeID, nodeData: NodeData) throws {
        try insertNode(node, at: existingNode, edge: edge, nodeData: nodeData, edgeData: ())
    }
}

public extension EditableTree where NodeData: DefaultConstructable, EdgeData: DefaultConstructable {
    mutating func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID) throws {
        try newNode(node, parent: parent, edge: edge, nodeData: NodeData(), edgeData: EdgeData())
    }
    
    mutating func insertNode(_ node: NodeID, at existingNode: NodeID, edge: EdgeID) throws {
        try insertNode(node, at: existingNode, edge: edge, nodeData: NodeData(), edgeData: EdgeData())
    }
}

public extension EditableTree where NodeData == Void, EdgeData == Void {
    mutating func newNode(_ node: NodeID, parent: NodeID, edge: EdgeID) throws {
        try newNode(node, parent: parent, edge: edge, nodeData: (), edgeData: ())
    }
    
    mutating func insertNode(_ node: NodeID, at existingNode: NodeID, edge: EdgeID) throws {
        try insertNode(node, at: existingNode, edge: edge, nodeData: (), edgeData: ())
    }
}
