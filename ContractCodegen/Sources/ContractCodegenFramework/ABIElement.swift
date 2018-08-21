public enum ABIElement: Decodable {
    case function(Function)
    case event(Event)

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)
        switch type {
        case "function", "constructor", "fallback":
            self = .function(try Function.init(from: decoder))
        case "event":
            self = .event(try Event(from: decoder))
        default: throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "unknown type of ABI Element"))
        }
    }
}

extension ABIElement {
    public func renderToSwift() -> String {
        switch self {
        case let .function(f): return f.renderToSwift()
        case let .event(e): return e.renderToSwift()
        }
    }
}
