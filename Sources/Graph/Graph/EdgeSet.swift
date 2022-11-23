import Foundation
import OrderedCollections
import SortedCollections
import WolfBase

public protocol EdgeSet<EdgeID> {
    associatedtype EdgeID: ElementID

    var isEmpty: Bool { get }
    var count: Int { get }
    mutating func insert(_ newMember: EdgeID)
    mutating func insert(_ newMember: EdgeID, at index: Int) throws
    mutating func remove(_ member: EdgeID)
    func union<S: Sequence>(_ s: S) -> SortedSet<EdgeID> where S.Element == EdgeID
    func filter(_ isIncluded: (EdgeID) -> Bool) -> Self
    func map<T>(_ transform: (EdgeID) throws -> T) rethrows -> [T]
    func index(of edge: EdgeID) throws -> Int
    
    var array: [EdgeID] { get }
}

public struct SortedEdgeSet<EdgeID>: EdgeSet where EdgeID: ElementID {
    var _set: SortedSet<EdgeID>
    
    init(_ _set: SortedSet<EdgeID>) {
        self._set = _set
    }
    
    init() {
        self.init([])
    }
    
    public var isEmpty: Bool { _set.isEmpty }
    public var count: Int { _set.count }
    
    public mutating func insert(_ newMember: EdgeID) {
        _set.insert(newMember)
    }
    
    public mutating func insert(_ newMember: EdgeID, at index: Int) throws {
        throw GraphError.notOrdered
    }
    
    public mutating func remove(_ member: EdgeID) {
        _set.remove(member)
    }
    
    public func union<S: Sequence>(_ s: S) -> SortedSet<EdgeID> where S.Element == EdgeID {
        _set.union(SortedSet(s))
    }
    
    public func filter(_ isIncluded: (EdgeID) -> Bool) -> Self {
        Self(_set.filter(isIncluded))
    }
    
    public func map<T>(_ transform: (EdgeID) throws -> T) rethrows -> [T] {
        try _set.map(transform)
    }
    
    /// - Complexity: O(*n*), where *n* is the length of the collection
    public func index(of edge: EdgeID) throws -> Int {
        guard let index = array.firstIndex(of: edge) else {
            throw GraphError.notFound
        }
        return index
    }
    
    public var array: [EdgeID] {
        Array(_set)
    }
}

public struct OrderedEdgeSet<EdgeID>: EdgeSet where EdgeID: ElementID {
    var _set: OrderedSet<EdgeID>
    
    init(_ _set: OrderedSet<EdgeID>) {
        self._set = _set
    }

    init() {
        self.init([])
    }

    public var isEmpty: Bool { _set.isEmpty }
    public var count: Int { _set.count }

    public mutating func insert(_ newMember: EdgeID) {
        _set.append(newMember)
    }
    
    public mutating func insert(_ newMember: EdgeID, at index: Int) throws {
        guard (0..._set.count).contains(index) else {
            throw GraphError.invalidIndex
        }
        _set.insert(newMember, at: index)
    }

    public mutating func remove(_ member: EdgeID) {
        _set.remove(member)
    }

    public func union<S: Sequence>(_ s: S) -> SortedSet<EdgeID> where S.Element == EdgeID {
        SortedSet(_set).union(SortedSet(s))
    }
    
    public func filter(_ isIncluded: (EdgeID) -> Bool) -> Self {
        Self(_set.filter(isIncluded))
    }
    
    public func map<T>(_ transform: (EdgeID) throws -> T) rethrows -> [T] {
        try _set.map(transform)
    }
    
    /// - Complexity: O(1)
    public func index(of edge: EdgeID) throws -> Int {
        guard let index = _set.firstIndex(of: edge) else {
            throw GraphError.notFound
        }
        return index
    }

    public var array: [EdgeID] {
        Array(_set)
    }
}
