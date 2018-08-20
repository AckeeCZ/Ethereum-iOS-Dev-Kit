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
    let isConstant: Bool?
    let isPayable: Bool?
}


struct Event: Decodable {
    struct Param: Decodable {
        let name: String
        let type: String
        let isIndexed: Bool
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
        static func \(name)(\(params)) -> (\(returnType)) {
        //TODO: just serialize parameters and call sendRawTransaction
        guard let data = params.data(using: .utf8) else { fatalError() }
        Run.send(rawTransaction: data, onSuccess: { _ in })
        }
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

class GenerateCommand: Command {

    let name = "generate"
    let shortDescription = "Generates the contract code"

    let file = Parameter()
    // TODO: Add second parameter for output directory (or Flag ... ?)

    func execute() throws {
        let arguments = CommandLine.arguments
        if arguments.count == 2 {

            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

                do {
                    let fileURL = dir.appendingPathComponent(arguments[1])
                    print(fileURL.absoluteString)
                    let abiData = try Data(contentsOf: fileURL, options: .mappedIfSafe)
                    let contractHeaders = try! JSONDecoder().decode([ABIElement].self, from: abiData)

                    let swiftCode = contractHeaders.reduce("""
                protocol FooContract: EthereumCommand {

            """
                    ) {
                        $0 + $1.renderToSwift()
                        } + "\n}"

                    print("HELLO")
                    print(swiftCode)

                    stdout <<< "✅"
                } catch {
                    // handle error
                }


            }
        } else {
            // TODO: Ask user to enter just a different name
            stdout <<< "Hello world!"
        }
    }
}

let generatorCLI = CLI(singleCommand: GenerateCommand())

let generator = ZshCompletionGenerator(cli: generatorCLI)
generator.writeCompletions()

generatorCLI.go()


