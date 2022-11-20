import XCTest
import Graph

//fileprivate typealias GraphType = Graph<Int, Int, String, Void, Void>
//fileprivate typealias TreeType = Tree<GraphType>
//fileprivate typealias NodeID = TreeType.NodeID
//
//fileprivate func makeTree(_ gen: inout IDGen) -> TreeType {
//    var graph = GraphType()
//    let root = gen.nextNode
//    try! graph.newNode(root, data: "f")
//    return try! TreeType(graph: graph, root: root)
//}
//
//fileprivate func _addChild(_ data: String, to: inout TreeType) -> NodeID {
//    
//}
//
////final class TreeEditTest: XCTestCase {
////    func test1() throws {
////        var gen = IDGen()
////        
////        func makeTree() -> TreeType { _makeTree(&gen) }
////        
////        var tree = makeTree()
////        
////        func addChild(_ data: String) -> NodeID {
////            
////        }
////        
////        tree.newNode(gen.nextNode, parent: <#T##Int#>, edge: <#T##Int#>, edgeData: <#T##Void#>)
////    }
////}
//
//struct IDGen {
//    private var _nextNode: Int = 0
//    private var _nextEdge: Int = 0
//    
//    var nextNode: Int {
//        mutating get {
//            defer { _nextNode += 1 }
//            return _nextNode
//        }
//    }
//    
//    var nextEdge: Int {
//        mutating get {
//            defer { _nextEdge += 1 }
//            return _nextEdge
//        }
//    }
//}
