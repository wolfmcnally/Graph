import Foundation

/// `Empty` is an uninhabited struct that when used for `NodeData` or `EdgeData` satisfies the requirements for the graph to be `Codable` and `Equatable`.
public struct Empty: Codable, Equatable, DefaultConstructable {
    public init() { }
}
