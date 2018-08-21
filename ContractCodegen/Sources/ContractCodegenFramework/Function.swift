public struct Function: Decodable {

    public struct Param: Decodable {
        public let name: String
        public let type: String
    }

    public let name: String
    public let inputs: [Param]
    public let outputs: [Param]
    public let isConstant: Bool?
    public let isPayable: Bool?
}

extension Function {
    public func renderToSwift() -> String {
        let params = inputs.map { $0.renderToSwift() }.joined(separator: ",")
        let returnType = outputs.map { $0.renderToSwift()}.joined(separator: ",")

        return """
        func \(name)(\(params)) -> (\(returnType))
        """
    }
}

extension Function.Param {
    public func renderToSwift() -> String {
        return name + ": " + type
    }
}
