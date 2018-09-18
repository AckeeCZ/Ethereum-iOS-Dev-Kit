//
//  ContractIntegrationTests.swift
//  UnitTests
//
//  Created by Marek Fořt on 9/11/18.
//

import XCTest
import EtherKit
import BigInt
@testable import EthereumProjectTemplate

class ContractIntegrationTests: XCTestCase {

    let query = EtherQuery(URL(string: "https://geth-infrastruktura-master.ack.ee")!, connectionMode: .http)
    let testContractAddress = try! Address(describing: "0xb8f016F3529b198b4a06574f3E9BDc04948ad852")
    var myAddress: Address!
    var key: HDKey.Private!

    override func setUp() {

        // Create key and after unlocking it run the tests s
        let createKeyExpectation = expectation(description: "Create Key")

        let sentence: Mnemonic.MnemonicSentence = Mnemonic.MnemonicSentence(["truly", "law", "tide", "pony", "media", "degree", "two", "goat", "ignore", "twice", "project", "message", "vanish", "spring", "movie"])
        let walletStorage = KeychainStorageStrategy(identifier: "cz.ackee.etherkit.tests")
        _ = walletStorage.delete()
        HDKey.Private.create(
            with: MnemonicStorageStrategy(walletStorage),
            mnemonic: sentence,
            network: .rinkeby,
            path: [
                KeyPathNode(at: 44, hardened: true),
                KeyPathNode(at: 60, hardened: true),
                KeyPathNode(at: 0, hardened: true),
                KeyPathNode(at: 1),
                ]
        ) { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let privateKey):
                self.key = privateKey
                privateKey.unlocked { value in
                        DispatchQueue.main.async {
                            _ = value.map { key in
                                self.myAddress = key.publicKey.address
                                createKeyExpectation.fulfill()
                            }
                        }
                    }
                }
            }
        waitForExpectations(timeout: 3)
    }

    func testUint8() {
        let testUint8Expectation = expectation(description: "Uint8")
        query.testContract(at: testContractAddress).testUint8(decimalUnits: 1).send(using: key, amount: Wei(1)).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testUint8Expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testData() {
        let testDataExpectation = expectation(description: "Data")
        query.testContract(at: testContractAddress).testData(extraData: Data("extra data".utf8)).send(using: key, amount: Wei(1)).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testDataExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testUintArray() {
        let testUintArrayExpectation = expectation(description: "UintArray")
        query.testContract(at: testContractAddress).testUintArray(uintArray: [BigUInt(1)]).send(using: key, amount: Wei(1)).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testUintArrayExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testBytes32Array() {
        let testBytes32ArrayExpectation = expectation(description: "Bytes32")
        query.testContract(at: testContractAddress).testBytes32Array(bytesArray: [Data("bytes 32 data".utf8)]).send(using: key, amount: Wei(1)).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testBytes32ArrayExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testBool() {
        let testBoolExpectation = expectation(description: "Bool")
        query.testContract(at: testContractAddress).testBool(trueOrFalse: true).send(using: key, amount: Wei(1)).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testBoolExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testInt8() {
        let testInt8Expectation = expectation(description: "Int8")
        query.testContract(at: testContractAddress).testInt8(value: 1).send(using: key, amount: Wei(1)).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testInt8Expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testInt256() {
        let testInt256Expectation = expectation(description: "Int256")
        query.testContract(at: testContractAddress).testInt256(value: BigInt(1)).send(using: key, amount: Wei(1)).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testInt256Expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testString() {
        let testStringExpectation = expectation(description: "String")
        query.testContract(at: testContractAddress).testString(greetString: "Hi").send(using: key, amount: Wei(1)).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testStringExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testLongString() {
        let testLongStringExpectation = expectation(description: "Long String")
        query.testContract(at: testContractAddress).testString(greetString: "This is is a very long string, This is is a very long string, This is is a very long string, This is is a very long string, This is is a very long string, This is is a very long string, This is is a very long string, This is is a very long string, This is is a very long string, This is is a very long string").send(using: key, amount: Wei(1)).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testLongStringExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testViewFunc() {
        let testViewFuncExpectation = expectation(description: "View Func")
        query.testContract(at: testContractAddress).totalSupply().send(using: key).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testViewFuncExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testMutatingFunc() {
        let testBuyFuncExpectation = expectation(description: "Mutating Func")
        query.testContract(at: testContractAddress).approve(spender: myAddress, value: BigUInt(10000000000)).send(using: key).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testBuyFuncExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

}
