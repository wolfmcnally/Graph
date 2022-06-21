import Foundation

public protocol ElementID: Hashable, Comparable, Codable, CustomStringConvertible {
}

extension Int: ElementID { }
extension String: ElementID { }
