import Foundation

public protocol ElementData: Hashable, Codable, DefaultConstructable {
}

extension String: ElementData { }
