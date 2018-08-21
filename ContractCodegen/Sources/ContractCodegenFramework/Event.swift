public struct Event: Decodable {
    public struct Param: Decodable {
        public let name: String
        public let type: String
        // TODO: indexed -> isIndexed
        public let isIndexed: Bool?
    }

    public let name: String
    public let inputs: [Param]
}

extension Event {
    public func renderToSwift() -> String {
        //        let params = inputs.map { $0.renderToSwift() }.joined(separator: ",")

        return ""
    }
}

extension Event.Param {
    public func renderToSwift() -> String {
        return name + ": " + type
    }
}
