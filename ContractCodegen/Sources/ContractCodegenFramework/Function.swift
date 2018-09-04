public struct Function: Decodable {

    public struct Param: Decodable {
        public let name: String
        public let type: String
    }

    public let name: String
    public let inputs: [Input]
    public let outputs: [Output]
    public let isConstant: Bool
    public let isPayable: Bool

    public struct Output {
        /// FunctionOutput names can also be empty strings.
        public let name: String
        public let type: ParameterType
    }

    public struct Input {
        public let name: String
        public let type: ParameterType
    }

    /// Specifies the type that parameters in a contract have.
    public enum ParameterType {
        case dynamicType(DynamicType)
        case staticType(StaticType)

        /// Denotes any type that has a fixed length.
        public enum StaticType {
            /// uint<M>: unsigned integer type of M bits, 0 < M <= 256, M % 8 == 0. e.g. uint32, uint8, uint256.
            case uint(bits: Int)
            /// int<M>: two's complement signed integer type of M bits, 0 < M <= 256, M % 8 == 0.
            case int(bits: Int)
            /// address: equivalent to uint160, except for the assumed interpretation and language typing.
            case address
            /// bool: equivalent to uint8 restricted to the values 0 and 1
            case bool
            /// bytes<M>: binary type of M bytes, 0 < M <= 32.
            case bytes(length: Int)
            /// function: equivalent to bytes24: an address, followed by a function selector
            case function
            /// <type>[M]: a fixed-length array of the given fixed-length type.
            indirect case array(StaticType, length: Int)

            // The specification also defines the following types:
            // uint, int: synonyms for uint256, int256 respectively (not to be used for computing the function selector).
            // We do not include these in this enum, as we will just be mapping those
            // to .uint(bits: 256) and .int(bits: 256) directly.
        }

        /// Denotes any type that has a variable length.
        public enum DynamicType {
            /// bytes: dynamic sized byte sequence.
            case bytes
            /// string: dynamic sized unicode string assumed to be UTF-8 encoded.
            case string
            /// <type>[]: a variable-length array of the given fixed-length type.
            case array(StaticType)
        }
    }

    enum CodingKeys: String, CodingKey {
        case name
        case inputs
        case outputs
        case isConstant = "constant"
        case isPayable = "payable"
    }

    public init(name: String, inputs: [Input], outputs: [Output], isConstant: Bool, isPayable: Bool) {
        self.name = name
        self.inputs = inputs
        self.outputs = outputs
        self.isConstant = isConstant
        self.isPayable = isPayable
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let name = try values.decode(String.self, forKey: .name)
        let inputJson = try values.decode([[String: String]].self, forKey: .inputs)
        let inputs = try Function.parseFunctionInputs(from: inputJson)
        let isConstant = try values.decodeIfPresent(Bool.self, forKey: .isConstant) ?? false
        let isPayable = try values.decodeIfPresent(Bool.self, forKey: .isPayable) ?? false
        self.init(name: name, inputs: inputs, outputs: [], isConstant: isConstant, isPayable: isPayable)
    }

    /// Parses the list of function inputs contained in a Json dictionary.
    ///
    /// - Parameter json: Dictionary describing a function. This dictionary should
    ///     include the key `inputs`. Otherwise an empty list is returned.
    /// - Returns: The list of `FunctionInput`s or an empty list.
    /// - Throws: Throws a ParsingError in case the json was malformed or there
    ///     was an error.
    private static func parseFunctionInputs(from json: [[String: String]]) throws -> [Input] {
        return try json.map { try Function.parseFunctionInput(from: $0) }
    }

    /// Parses the function input contained in the Json dictionary.
    ///
    /// - Parameter json: Dictionary describing an Input to a function.
    /// - Returns: The corresponding FunctionInput.
    /// - Throws: Throws a ParsingError in case the json was malformed or there
    ///     was an error.
    private static func parseFunctionInput(from json: [String: String]) throws -> Function.Input {
        guard let name = json["name"] else {
            throw ParsingError.elementNameInvalid
        }
        let type = try ParameterParser.parseParameterType(from: json)
        return Function.Input(name: name, type: type)
    }
}

extension Function.Input {
    public var abiTypeString: String {
        return type.abiTypeString(value: name)
    }
}

// MARK: Render to swift
extension Function.ParameterType {
    var generatedTypeString: String {
        switch self {
        case let .staticType(wrappedType):
            return wrappedType.generatedTypeString
        case let .dynamicType(wrappedType):
            return wrappedType.generatedTypeString
        }
    }

    func abiTypeString(value: String) -> String {
        switch self {
        case let .staticType(wrappedType):
            return wrappedType.abiTypeString(value: value)
        case let .dynamicType(wrappedType):
            return wrappedType.abiTypeString(value: value)
        }
    }

    var isDynamic: Bool {
        switch self {
        case .dynamicType(_):
            return true
        case .staticType(_):
            return false
        }
    }
}

extension Function.ParameterType.StaticType {
    var generatedTypeString: String {
        let nonPrefixedTypeString: String
        switch self {
        case .uint(let bits):
            nonPrefixedTypeString = bits > 64 ? "BigUInt" : "UInt"
        case .int(let bits):
            nonPrefixedTypeString = bits > 64 ? "BigInt" : "Int"
        case .address:
            nonPrefixedTypeString = "Address"
        case .bool:
            nonPrefixedTypeString = "Bool"
        case .bytes(_):
            nonPrefixedTypeString = "Data"
        case .function:
            nonPrefixedTypeString = "Function"
        case let .array(type, length: _):
            let innerType = type.generatedTypeString
            nonPrefixedTypeString = "Array<\(innerType)>"
        }
        return nonPrefixedTypeString
    }
}

extension Function.ParameterType.StaticType {
    func abiTypeString(value: String) -> String {
        let abiString: String
        switch self {
        case .uint(let bits):
            abiString = ".uint(size: \(bits), value: \(value))"
        case .int(let bits):
            abiString = ".int(size: \(bits), value: \(value))"
        case .address:
            abiString = ".address(value: \(value))"
        case .bool:
            abiString = ".bool(value: \(value))"
        case .bytes(let length):
            abiString = "(count: .bytes(.constrained(\(length)), value: \(value))"
        case .function:
            abiString = ".functionSelector(name: \(value).functionSelector.name, parameterTypes: \(value).functionSelector.parameterTypes, contract: \(value).functionSelector.contract"
        case let .array(type, length: length):
            abiString = ".array(count: .constrained(\(length)), type: \(type.abiTypeString), contract: self.at)"
        }
        return abiString
    }
}

extension Function.ParameterType.DynamicType {
    var generatedTypeString: String {
        let nonPrefixedTypeString: String
        switch self {
        case .bytes:
            nonPrefixedTypeString = "Data"
        case .string:
            nonPrefixedTypeString = "String"
        case .array(let type):
            let innerType = type.generatedTypeString
            nonPrefixedTypeString = "Array<\(innerType)>"
        }
        return nonPrefixedTypeString
    }
}

extension Function.ParameterType.DynamicType {
    func abiTypeString(value: String) -> String {
        let abiString: String
        switch self {
        case .bytes:
            abiString = ".bytes(count: .unlimited, value: \(value))"
        case .string:
            abiString = ".string(value: \(value))"
        case .array(let type):
            abiString = ".array(count: .unlimited, type: \(type.abiTypeString), value: \(value))"
        }
        return abiString
    }
}


extension Function.Output {
    public func renderToSwift() -> String {
        return name + ": " + type.generatedTypeString
    }
}

extension Function.Input {
    public func renderToSwift() -> String {
        return name + ": " + type.generatedTypeString
    }
}

extension Function {
    public func renderToSwift() -> String {
        let params = inputs.map { $0.renderToSwift() }.joined(separator: ",")
        let returnType = outputs.map { $0.renderToSwift() }.joined(separator: ",")

        return """
        func \(name)(\(params)) -> (\(returnType))
        """
    }
}
