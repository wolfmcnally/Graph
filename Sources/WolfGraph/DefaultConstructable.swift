import Foundation

public protocol DefaultConstructable {
    init()
}

extension String: DefaultConstructable { }
