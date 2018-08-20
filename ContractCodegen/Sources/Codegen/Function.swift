struct Function: Decodable {

    struct Param: Decodable {
        let name: String
        let type: String
    }

    let name: String
    let inputs: [Param]
    let outputs: [Param]
    let isConstant: Bool?
    let isPayable: Bool?
}
