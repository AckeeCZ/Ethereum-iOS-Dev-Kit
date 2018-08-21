#!/usr/bin/swift

import Foundation
import SwiftCLI

//contract Test {
//    function Test(){ b = 0x12345678901234567890123456789012; }
//    event Event(uint indexed a, bytes32 b);
//    event Event2(uint indexed a, bytes32 b);
//    function foo(uint a) { Event(a, b); }
//    bytes32 b;
//}

let abi =
    """
    [{
    "type":"event",
    "inputs": [{"name":"a","type":"uint256","indexed":true},{"name":"b","type":"bytes32","indexed":false}],
    "name":"Event"
    }, {
        "type":"event",
        "inputs": [{"name":"a","type":"uint256","indexed":true},{"name":"b","type":"bytes32","indexed":false}],
        "name":"Event2"
    }, {
        "type":"function",
        "inputs": [{"name":"a","type":"uint256"}],
        "name":"foo",
        "outputs": [{"name":"result", "type":"Bar"}]
    }]
    """.data(using: .utf8)!

// TODO: Move to another file
struct Function: Decodable {

    struct Param: Decodable {
        let name: String
        let type: String
    }

    let name: String
    let inputs: [Param]
    let outputs: [Param]
    // TODO: Same as isIndexed
    let isConstant: Bool?
    let isPayable: Bool?
}


struct Event: Decodable {
    struct Param: Decodable {
        let name: String
        let type: String
        // TODO: indexed -> isIndexed
        let isIndexed: Bool?
    }

    let name: String
    let inputs: [Param]
}

enum ABIElement: Decodable {
    case function(Function)
    case event(Event)

    enum CodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
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
    func renderToSwift() -> String {
        switch self {
        case let .function(f): return f.renderToSwift()
        case let .event(e): return e.renderToSwift()
        }
    }
}

extension Event {
    func renderToSwift() -> String {
        //        let params = inputs.map { $0.renderToSwift() }.joined(separator: ",")

        return ""
    }
}

extension Event.Param {
    func renderToSwift() -> String {
        return name + ": " + type
    }
}

extension Function {
    func renderToSwift() -> String {
        let params = inputs.map { $0.renderToSwift() }.joined(separator: ",")
        let returnType = outputs.map { $0.renderToSwift()}.joined(separator: ",")

        return """
        func \(name)(\(params)) -> (\(returnType))
        """
    }
}

extension Function.Param {
    func renderToSwift() -> String {
        return name + ": " + type
    }
}


//mock EtherKit for now
struct Hash { let value: String }
typealias Wei = Int //BigInt
class EtherKit {
    func send(rawTransaction data: Data, completion: (Hash) -> ()) {
        print("sending transaction")
        print("--------------------")
        print(data)
        print("--------------------")
        completion(Hash(value: "zhulenejHash"))
    }
}


protocol Command { //TODO: Monoid
    associatedtype Message
}

struct Run<Message>: Command {
    typealias Context = EtherKit
    //    public static var empty: Run<Action> { return Run { _ in }}
    //
    //    public static func <> (lhs: Run<Message>, rhs: Run<Message>) -> Run<Action> {
    //        return Run { callback in
    //            lhs.run(callback)
    //            rhs.run(callback)
    //        }
    //    }

    public let run: (_ context: Context, _ callback: @escaping (Message) -> ()) -> ()
    public init(run: @escaping (Context, @escaping (Message) -> ()) -> ()) {
        self.run = run
    }
}

protocol EthereumCommand: Command {
    static func send(rawTransaction data: Data, onSuccess: @escaping (Hash) -> Message) -> Self
}

extension Run: EthereumCommand {
    static func send(rawTransaction data: Data, onSuccess: @escaping (Hash) -> Message) -> Run<Message> {
        return Run { etherKit, callback in
            etherKit.send(rawTransaction: data) { callback(onSuccess($0)) }
        }
    }
}

protocol ExampleSmartContract: EthereumCommand {
    static func foo(bar: String, amount: Wei, onSuccess: @escaping () -> Message) -> Self
}
extension Run: ExampleSmartContract {
    static func foo(bar: String, amount: Wei, onSuccess: @escaping () -> Message) -> Run<Message> {
        return Run { etherKit, callback in
            print("calling foo")
            let data = bar.data(using: .utf8)!
            Run<Message>.send(rawTransaction: data) { _ in onSuccess() }.run(etherKit, callback)
            print("did call foo")
        }
    }
}

//class ViewModel {
//    let etherKit: EtherKit = .init()
//
//    enum TestMessage {
//        case yay
//    }
//    init() {
//        Run<TestMessage>
//            .foo(bar: "bar", amount: 42) { .yay }
//            .run(etherKit) { [weak self] in self?.handle(message: $0) }
//    }
//
//    func handle(message: TestMessage) {
//        print(message)
//    }
//}
//
//ViewModel()

//import ReactiveSwift
//import EtherKit
//import Foundation
//import BigInt
//
//extension EtherQuery {
//    func helloWorldContract(at: String) -> EtherQuery {
//        return self
//    }
//
//    func foo(bar: String) -> (_ using: EtherKeyManager, _ from: Address, _ to: Address, _ amount: UInt256) -> SignalProducer<Hash, EtherKitError> {
//        return { using, from, to, amount in
//            return SignalProducer<Hash, EtherKitError> { observer, disposable in
//                //pass the params representing calling this function in the proper format to etherkit
//                guard let paramsData = "foo(bar: \(bar)".data(using: .utf8) else {
//                    observer.send(error: EtherKitError.web3Failure(reason: .parsingFailure))
//                    return
//                }
//                self.send(using: using, from: from, to: to, value: amount, data: GeneralData(data: paramsData), completion: { result in
//                    switch result {
//                    case .success(let hash):
//                        observer.send(value: hash)
//                    case .failure(let error):
//                        observer.send(error: error)
//                        observer.sendCompleted()
//                    }
//                })
//            }
//        }
//    }
//}
//
//protocol HelloWorldContract: EthereumCommand {
//    static func foo(bar: String, amount: Wei, onSuccess: @escaping () -> Message) -> Self
//}
//
//extension HelloWorldContract {
//    static func foo(bar: String, amount: Wei, onSuccess: @escaping () -> Message) -> Self {
//        guard let data = params.data(using: .utf8) else { fatalError() }
//        Run.send(rawTransaction: data, onSuccess: { _ in })
//        return self
//    }
//}


private func isFunction(_ element: ABIElement) -> Bool {
    switch element {
    case .function(_):
        return true
    case .event(_):
        return false
    }
}

private func generateFuncStringIfNecessary(with element: ABIElement) -> String {
    if isFunction(element) {
        return """
         {
        guard let data = params.data(using: .utf8) else { fatalError() }
        Run.send(rawTransaction: data, onSuccess: { _ in })
        }
        """
    } else {
        return ""
    }
}

private func generateExtensionFuncString(with function: Function) -> String {
    return """
        \nfunc \(function.name)(\(function.inputs.map { $0.renderToSwift() }.joined(separator: ", "))) -> (_ using: EtherKeyManager, _ from: Address, _ to: Address, _ amount: UInt256) -> SignalProducer<Hash, EtherKitError> {
            return { using, from, to, amount in
                return SignalProducer<Hash, EtherKitError> { observer, disposable in
                    //pass the params representing calling this function in the proper format to etherkit
                    guard let paramsData = "foo(bar: barrrrrrrrrrr".data(using: .utf8) else {
                        observer.send(error: EtherKitError.web3Failure(reason: .parsingFailure))
                        return
                    }
                    self.send(using: using, from: from, to: to, value: amount, data: GeneralData(data: paramsData), completion: { result in
                        switch result {
                        case .success(let hash):
                            observer.send(value: hash)
                        case .failure(let error):
                            observer.send(error: error)
                            observer.sendCompleted()
                        }
                    })
                }
            }
        }
    }
    """
}

class GenerateCommand: SwiftCLI.Command {

    let name = "generate"
    let shortDescription = "Generates Swift code for contract"

    let contractName = Parameter(completion: .none)
    let file = Parameter(completion: .filename)
    // TODO: Add second parameter for output directory (or Flag ... ?)

    func execute() throws {
        let arguments = CommandLine.arguments
        if arguments.count == 3 {

            let fileURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/" + arguments[2])
            do {
                let importModulesString = """
                import ReactiveSwift
                import EtherKit
                import Foundation
                import BigInt\n\n
                """


                let abiData = try Data(contentsOf: fileURL, options: .mappedIfSafe)
                let contractHeaders = try JSONDecoder().decode([ABIElement].self, from: abiData)


                let funcs: [Function] = contractHeaders.compactMap {
                    switch $0 {
                    case .function(let f): return f
                    case .event(_): return nil
                    }
                }
                let renderedFuncs = funcs.map { $0.renderToSwift() }
                let protocolFuncDeclarations = renderedFuncs.map { "static " + $0 }.joined(separator: "\n")
                let protocolCode = renderedFuncs.reduce(
                    // TODO: Can this string be better formatted for the alignment of the other code?
                    """
                    protocol \(contractName.value): EthereumCommand {
                        \(protocolFuncDeclarations)
                    }

                    extension \(contractName.value) {\n
                    """
                ) {
                    $0 + "static " + $1 + """
                     {
                        guard let data = params.data(using: .utf8) else { fatalError() }
                        Run.send(rawTransaction: data, onSuccess: { _ in })
                    }
                    """
                    } + "\n}"

                // TODO: Add events to string here

                var extensionCode = """
                \n
                extension EtherQuery {
                    func \(contractName.value)(at: String) -> EtherQuery {
                    return self
                }
            """

                extensionCode += funcs.map { generateExtensionFuncString(with: $0) }.joined(separator: "\n")

                let swiftCode = importModulesString + protocolCode + extensionCode
                // TODO: Add to real project
                // let swiftCodeURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/" + "contract.swift")
                let swiftCodeURL = URL(fileURLWithPath: "/Users/marekfort/Development/ackee/EthereumProjectTemplate_copy/Skeleton/contract.swift")

                try swiftCode.write(to: swiftCodeURL, atomically: true, encoding: .utf8)
                print(FileManager.default.currentDirectoryPath + "/" + "contract.swift")

                stdout <<< "✅"
            } catch {
                stdout <<< "Error!"
                // handle error
            }
        } else {
            // TODO: Ask user to enter a different name
            stdout <<< "Hello world!"
        }
    }
}

let generatorCLI = CLI(singleCommand: GenerateCommand())

let generator = ZshCompletionGenerator(cli: generatorCLI)
generator.writeCompletions()

generatorCLI.goAndExit()
