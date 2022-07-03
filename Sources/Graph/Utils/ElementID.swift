import Foundation

public protocol ElementID: Hashable, Comparable, CustomStringConvertible {
}

extension Int: ElementID { }
extension String: ElementID { }
