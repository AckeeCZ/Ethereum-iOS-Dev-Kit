#!/usr/bin/swift

import Foundation
import SwiftCLI
import ContractCodegenFramework

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

let generatorCLI = CLI(singleCommand: GenerateCommand())

let generator = ZshCompletionGenerator(cli: generatorCLI)
generator.writeCompletions()

generatorCLI.goAndExit()
