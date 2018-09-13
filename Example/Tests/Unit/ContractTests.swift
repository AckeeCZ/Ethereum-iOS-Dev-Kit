//
//  ContractTests.swift
//  UnitTests
//
//  Created by Marek Fořt on 9/11/18.
//

import XCTest
import EtherKit
import BigInt
@testable import EthereumProjectTemplate

class ContractTests: XCTestCase {

    let query = EtherQuery(URL(string: "https://geth-infrastruktura-master.ack.ee")!, connectionMode: .http)
    let testContractAddress = try! Address(describing: "0xb8f016F3529b198b4a06574f3E9BDc04948ad852")
    let myAddress = try! Address(describing: "0x0d40C4Ef13DfEaE7BB930f84aA3e5733aCab0Bb5")
    // TODO: Is this the best way to init the key (optional, non-optional with {} ... )
    var key: HDKey.Private!

    override func setUp() {
        let walletStorage = KeychainStorageStrategy(identifier: "cz.ackee.etherkit.example")
        // TODO: Tests should wait before this key is created and then accessed!
        let key = HDKey.Private(walletStorage, network: .rinkeby, path: [
            KeyPathNode(at: 44, hardened: true),
            KeyPathNode(at: 60, hardened: true),
            KeyPathNode(at: 0, hardened: true),
            KeyPathNode(at: 1),
            ])
        self.key = key
    }

    func testUint8() {
        let testUint8Expectation = expectation(description: "Uint8")
        query.testContract(at: testContractAddress).testUint8(decimalUnits: UInt(1)).send(using: key, amount: Wei(1)).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testUint8Expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3, handler: nil)
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

        waitForExpectations(timeout: 3, handler: nil)
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

        waitForExpectations(timeout: 3, handler: nil)
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

        waitForExpectations(timeout: 3, handler: nil)
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

        waitForExpectations(timeout: 3, handler: nil)
    }

    func testInt8() {
        let testInt8Expectation = expectation(description: "Int8")
        query.testContract(at: testContractAddress).testInt8(value: 8).send(using: key, amount: Wei(1)).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testInt8Expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3, handler: nil)
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

        waitForExpectations(timeout: 3, handler: nil)
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

        waitForExpectations(timeout: 3, handler: nil)
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

        waitForExpectations(timeout: 3, handler: nil)
    }

    func testViewFunc() {
        let testViewFuncExpectation = expectation(description: "View Func")
        query.testContract(at: testContractAddress).testViewFunc().send(using: key).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testViewFuncExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3, handler: nil)
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

        waitForExpectations(timeout: 3, handler: nil)
    }

}
