import Foundation

public protocol DotEncodable: ViewableGraph {
    func nodeLabel(_ node: NodeID) -> String?
    func nodeColor(_ node: NodeID) -> String?
    func nodeStyle(_ node: NodeID) -> String?
    func nodeShape(_ node: NodeID) -> String?

    func edgeLabel(_ edge: EdgeID) -> String?
    func edgeColor(_ edge: EdgeID) -> String?
    func edgeStyle(_ edge: EdgeID) -> String?
}

public extension DotEncodable {
    func nodeLabel(_ node: NodeID) -> String? { nil }
    func nodeColor(_ node: NodeID) -> String? { nil }
    func nodeStyle(_ node: NodeID) -> String? { nil }
    func nodeShape(_ node: NodeID) -> String? { nil }

    func edgeLabel(_ edge: EdgeID) -> String? { nil }
    func edgeColor(_ edge: EdgeID) -> String? { nil }
    func edgeStyle(_ edge: EdgeID) -> String? { nil }
}

public extension DotEncodable {
    var dotFormat: String {
        var result: [String] = []
        
        func attribute(name: String, value: String) -> String {
            """
            [\(name)="\(value)"]
            """
        }

        result.append("digraph G {")
        
        for node in nodes {
            var line: [String] = ["\t"]
            line.append(node.description)
            if let label = nodeLabel(node) {
                line.append(attribute(name: "label", value: label))
            }
            if let color = nodeColor(node) {
                line.append(attribute(name: "color", value: color))
            }
            if let style = nodeStyle(node) {
                line.append(attribute(name: "style", value: style))
            }
            if let shape = nodeShape(node) {
                line.append(attribute(name: "shape", value: shape))
            }
            line.append(";")
            result.append(line.joined())
        }
        
        for edge in edges {
            var line: [String] = ["\t"]
            try! line.append(edgeTail(edge).description)
            line.append(" -> ")
            try! line.append(edgeHead(edge).description)
            if let label = edgeLabel(edge) {
                line.append(attribute(name: "label", value: label))
            }
            if let color = edgeColor(edge) {
                line.append(attribute(name: "color", value: color))
            }
            if let style = edgeStyle(edge) {
                line.append(attribute(name: "style", value: style))
            }
            line.append(";")
            result.append(line.joined())
        }
        
        result.append("}")
        
        return result.joined(separator: "\n")
    }
}
