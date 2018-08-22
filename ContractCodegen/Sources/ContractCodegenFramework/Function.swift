public struct Function: Decodable {

    public struct Param: Decodable {
        public let name: String
        public let type: String
    }

    public let name: String
    public let inputs: [ParameterType]
    public let outputs: [ParameterType]
    public let isConstant: Bool?
    public let isPayable: Bool?

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
