import Foundation

public protocol ElementData: Hashable, DefaultConstructable {
}

extension String: ElementData { }
