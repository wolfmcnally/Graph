import Foundation

public protocol DotEncodable: ViewableGraph {
    func dotNodeLabel(_ node: NodeID) -> String?
    func dotNodeColor(_ node: NodeID) -> String?
    func dotNodeStyle(_ node: NodeID) -> String?
    func dotNodeShape(_ node: NodeID) -> String?

    func dotEdgeLabel(_ edge: EdgeID) -> String?
    func dotEdgeColor(_ edge: EdgeID) -> String?
    func dotEdgeStyle(_ edge: EdgeID) -> String?
}

public extension DotEncodable {
    func dotNodeLabel(_ node: NodeID) -> String? { nil }
    func dotNodeColor(_ node: NodeID) -> String? { nil }
    func dotNodeStyle(_ node: NodeID) -> String? { nil }
    func dotNodeShape(_ node: NodeID) -> String? { nil }

    func dotEdgeLabel(_ edge: EdgeID) -> String? { nil }
    func dotEdgeColor(_ edge: EdgeID) -> String? { nil }
    func dotEdgeStyle(_ edge: EdgeID) -> String? { nil }
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
            if let label = dotNodeLabel(node) {
                line.append(attribute(name: "label", value: label))
            }
            if let color = dotNodeColor(node) {
                line.append(attribute(name: "color", value: color))
            }
            if let style = dotNodeStyle(node) {
                line.append(attribute(name: "style", value: style))
            }
            if let shape = dotNodeShape(node) {
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
            if let label = dotEdgeLabel(edge) {
                line.append(attribute(name: "label", value: label))
            }
            if let color = dotEdgeColor(edge) {
                line.append(attribute(name: "color", value: color))
            }
            if let style = dotEdgeStyle(edge) {
                line.append(attribute(name: "style", value: style))
            }
            line.append(";")
            result.append(line.joined())
        }
        
        result.append("}")
        
        return result.joined(separator: "\n")
    }
}
