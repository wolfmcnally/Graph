import Foundation

extension Sequence where Element: Comparable {
    func sortedIf(_ isSorted: Bool) -> [Element] {
        let a = Array(self)
        if isSorted {
            return a.sorted()
        } else {
            return a
        }
    }
}
