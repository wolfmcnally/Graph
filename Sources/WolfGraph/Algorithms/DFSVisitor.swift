import Foundation

public protocol DFSVisitor {
    associatedtype Graph: ViewableGraph
    associatedtype Result
    typealias NodeID = Graph.NodeID
    typealias EdgeID = Graph.EdgeID
    
    func initNode(_ node: NodeID) -> Result?
    func startNode(_ node: NodeID) -> Result?
    func discoverNode(_ node: NodeID) -> Result?
    func finishNode(_ node: NodeID) -> Result?
    
    func examineEdge(_ edge: EdgeID) -> Result?
    func treeEdge(_ edge: EdgeID) -> Result?
    func backEdge(_ edge: EdgeID) -> Result?
    func forwardOrCrosseEdge(_ edge: EdgeID) -> Result?
    func finishEdge(_ edge: EdgeID) -> Result?
    
    func finish() -> Result
}

public extension DFSVisitor {
    func initNode(_ node: NodeID) -> Result? { nil }
    func startNode(_ node: NodeID) -> Result? { nil }
    func discoverNode(_ node: NodeID) -> Result? { nil }
    func finishNode(_ node: NodeID) -> Result? { nil }
    
    func examineEdge(_ edge: EdgeID) -> Result? { nil }
    func treeEdge(_ edge: EdgeID) -> Result? { nil }
    func backEdge(_ edge: EdgeID) -> Result? { nil }
    func forwardOrCrosseEdge(_ edge: EdgeID) -> Result? { nil }
    func finishEdge(_ edge: EdgeID) -> Result? { nil }
}
