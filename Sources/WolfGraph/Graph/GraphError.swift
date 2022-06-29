import Foundation

public enum GraphError: Error {
    case notFound
    case duplicate
    case notATree
    case notADAG
    case notACompound
}
