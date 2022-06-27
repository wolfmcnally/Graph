import Foundation

public protocol DFSVisitor {
    associatedtype Graph: ViewableGraph
    associatedtype Result
    typealias NodeID = Graph.NodeID
    typealias EdgeID = Graph.EdgeID
    
    func initNode(_ node: NodeID) throws -> Result?
    func startNode(_ node: NodeID) throws -> Result?
    func discoverNode(_ node: NodeID) throws -> Result?
    func finishNode(_ node: NodeID) throws -> Result?
    
    func examineEdge(_ edge: EdgeID) throws -> Result?
    func treeEdge(_ edge: EdgeID) throws -> Result?
    func backEdge(_ edge: EdgeID) throws -> Result?
    func forwardOrCrosseEdge(_ edge: EdgeID) throws -> Result?
    func finishEdge(_ edge: EdgeID) throws -> Result?
    
    func finish() -> Result
}

public extension DFSVisitor {
    func initNode(_ node: NodeID) throws -> Result? { nil }
    func startNode(_ node: NodeID) throws -> Result? { nil }
    func discoverNode(_ node: NodeID) throws -> Result? { nil }
    func finishNode(_ node: NodeID) throws -> Result? { nil }
    
    func examineEdge(_ edge: EdgeID) throws -> Result? { nil }
    func treeEdge(_ edge: EdgeID) throws -> Result? { nil }
    func backEdge(_ edge: EdgeID) throws -> Result? { nil }
    func forwardOrCrosseEdge(_ edge: EdgeID) throws -> Result? { nil }
    func finishEdge(_ edge: EdgeID) throws -> Result? { nil }
}
