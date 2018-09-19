import Foundation
import XCTest
import PathKit
import SwiftCLI
import ContractCodegenFramework

class CommandLineToolTests: XCTestCase {

    private let generatedContractsString = "GeneratedContracts/"
    private let generatorCLI = CLI(singleCommand: GenerateCommand())

    func testGeneratedContractsFileCreated() throws {
        XCTAssertEqual(0, generatorCLI.debugGo(with: "generate TestContract ../abi.json"))
        XCTAssertTrue(Path(generatedContractsString).exists)

        try Path(generatedContractsString).delete()
    }

    func testTestContractFileCreated() throws {
        XCTAssertEqual(0, generatorCLI.debugGo(with: "generate TestContract ../abi.json"))
        XCTAssertTrue(Path(generatedContractsString + "TestContract.swift").exists)

        try Path(generatedContractsString).delete()
    }

    func testSharedContractFileCreated() throws {
        XCTAssertEqual(0, generatorCLI.debugGo(with: "generate TestContract ../abi.json"))
        XCTAssertTrue(Path(generatedContractsString + "SharedContract.swift").exists)

        try Path(generatedContractsString).delete()
    }

    func testOutputOption() throws {
        let outputPath = "Output/" + generatedContractsString
        XCTAssertEqual(0, generatorCLI.debugGo(with: "generate TestContract ../abi.json -o \(outputPath)"))

        XCTAssertTrue(Path(outputPath).exists)
        XCTAssertTrue(Path(outputPath + "SharedContract.swift").exists)
        XCTAssertTrue(Path(outputPath + "TestContract.swift").exists)

        try Path("Output").delete()
    }

    func testBytesArrayGen() throws {
        let abiJson = """
         [ {  "constant": false, "inputs": [ { "name": "bytesArray", "type": "bytes32[]" } ], "name": "testBytes32Array", "outputs": [ { "name": "", "type": "bytes32[]" } ], "payable": true, "stateMutability": "payable", "type": "function", "signature": "0xc530dbe5" } ]
        """
        let abiPath = Path("test_abi.json")
        try abiPath.write(abiJson)

        XCTAssertEqual(0, generatorCLI.debugGo(with: "generate TestContract test_abi.json"))

        let expectedSwiftCode = """
            // Generated using ContractGen
            // swiftlint:disable file_length

            import ReactiveSwift
            import EtherKit
            import BigInt

            struct TestContractBox {
                fileprivate let etherQuery: EtherQuerying
                fileprivate let at: Address

                init(etherQuery: EtherQuerying, at: Address) {
                    self.etherQuery = etherQuery
                    self.at = at
                }

                func testBytes32Array<T: PrivateKeyType>(bytesArray: Array<Data>) -> PayableContractMethodInvocation<T> {
                    let send: (_ using: T, _ amount: Wei) -> SignalProducer<Hash, EtherKitError> = { using, amount in
                        return SignalProducer<Hash, EtherKitError> { observer, disposable in
                            let testBytes32ArrayFunctionCall = Function(name: "testBytes32Array", parameters: [.array(count: .unlimited, type: .bytes(count: .constrained(32), value: Data()), value: bytesArray.map { .bytes(count: .constrained(32), value: $0) })] as [ABIType])
                            let testBytes32ArrayData = GeneralData(data: testBytes32ArrayFunctionCall.encodeToCall())
                            self.etherQuery.send(using: using, to: self.at, value: amount, data: testBytes32ArrayData, queue: DispatchQueue.global(qos: .default), completion: { result in
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
                    return PayableContractMethodInvocation(send: send)
                }
            }

            extension EtherQuery {
                func testContract(at: Address) -> TestContractBox {
                    return TestContractBox(etherQuery: self, at: at)
                }
            }

            """

        let generatedSwiftCodePath = Path(generatedContractsString) + Path("TestContract.swift")
        XCTAssertEqual(try generatedSwiftCodePath.read().replacingOccurrences(of: " ", with: ""), expectedSwiftCode.replacingOccurrences(of: " ", with: ""))

        try Path(generatedContractsString).delete()
        try Path("test_abi.json").delete()
    }

    func testContractPaymentGen() throws {
        let abiJson = """
         [ { "constant": true, "inputs": [], "name": "testViewFunc", "outputs": [ { "name": "", "type": "uint256", "value": "0" } ], "payable": false, "stateMutability": "view", "type": "function", "signature": "0x6bc18c20" } ]
        """
        let abiPath = Path("test_abi.json")
        try abiPath.write(abiJson)

        XCTAssertEqual(0, generatorCLI.debugGo(with: "generate TestContract test_abi.json"))

        let expectedSwiftCode = """
            // Generated using ContractGen
            // swiftlint:disable file_length

            import ReactiveSwift
            import EtherKit
            import BigInt

            struct TestContractBox {
                fileprivate let etherQuery: EtherQuerying
                fileprivate let at: Address

                init(etherQuery: EtherQuerying, at: Address) {
                    self.etherQuery = etherQuery
                    self.at = at
                }

                func testViewFunc<T: PrivateKeyType>() -> ContractMethodInvocation<T> {
                    let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
                        return SignalProducer<Hash, EtherKitError> { observer, disposable in
                            let testViewFuncFunctionCall = Function(name: "testViewFunc", parameters: [] as [ABIType])
                            let testViewFuncData = GeneralData(data: testViewFuncFunctionCall.encodeToCall())
                            self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: testViewFuncData, queue: DispatchQueue.global(qos: .default), completion: { result in
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
                    return ContractMethodInvocation(send: send)
                }
            }

            extension EtherQuery {
                func testContract(at: Address) -> TestContractBox {
                    return TestContractBox(etherQuery: self, at: at)
                }
            }

            """

        let generatedSwiftCodePath = Path(generatedContractsString) + Path("TestContract.swift")
        XCTAssertEqual(try generatedSwiftCodePath.read().replacingOccurrences(of: " ", with: ""), expectedSwiftCode.replacingOccurrences(of: " ", with: ""))

        try Path(generatedContractsString).delete()
        try Path("test_abi.json").delete()
    }

    func testFuncWithUserInputGen() throws {
        let abiJson = """
         [ { "constant": false, "inputs": [ { "name": "_spender", "type": "address" }, { "name": "_value", "type": "uint256" } ], "name": "approve", "outputs": [ { "name": "success", "type": "bool" } ], "payable": false, "stateMutability": "nonpayable", "type": "function", "signature": "0x095ea7b3" } ]
        """
        let abiPath = Path("test_abi.json")
        try abiPath.write(abiJson)

        XCTAssertEqual(0, generatorCLI.debugGo(with: "generate TestContract test_abi.json"))

        let expectedSwiftCode = """
            // Generated using ContractGen
            // swiftlint:disable file_length

            import ReactiveSwift
            import EtherKit
            import BigInt

            struct TestContractBox {
                fileprivate let etherQuery: EtherQuerying
                fileprivate let at: Address

                init(etherQuery: EtherQuerying, at: Address) {
                    self.etherQuery = etherQuery
                    self.at = at
                }

                func approve<T: PrivateKeyType>(spender: Address, value: BigUInt) -> ContractMethodInvocation<T> {
                    let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
                        return SignalProducer<Hash, EtherKitError> { observer, disposable in
                            let approveFunctionCall = Function(name: "approve", parameters: [spender.abiType, value.abiType] as [ABIType])
                            let approveData = GeneralData(data: approveFunctionCall.encodeToCall())
                            self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: approveData, queue: DispatchQueue.global(qos: .default), completion: { result in
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
                    return ContractMethodInvocation(send: send)
                }
            }

            extension EtherQuery {
                func testContract(at: Address) -> TestContractBox {
                    return TestContractBox(etherQuery: self, at: at)
                }
            }

            """

        let generatedSwiftCodePath = Path(generatedContractsString) + Path("TestContract.swift")
        XCTAssertEqual(try generatedSwiftCodePath.read().replacingOccurrences(of: " ", with: ""), expectedSwiftCode.replacingOccurrences(of: " ", with: ""))

        try Path(generatedContractsString).delete()
        try Path("test_abi.json").delete()
    }


}

