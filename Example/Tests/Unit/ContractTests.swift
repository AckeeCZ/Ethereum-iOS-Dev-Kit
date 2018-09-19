//
//  ContractTests.swift
//  UnitTests
//
//  Created by Marek Fořt on 9/18/18.
//

import XCTest
import EtherKit
import Result
@testable import EthereumProjectTemplate

class ContractTests: XCTestCase {

    let etherQueryMock = EtherQueryMock()
    let testContractAddress = try! Address(describing: "0xb8f016F3529b198b4a06574f3E9BDc04948ad852")
    var myAddress = try! Address(describing: "0xb8f016F3529b198b4a06574f3E9BDc04948ad852")
    var key = HDKey.Private(KeychainStorageStrategy(identifier: "cz.ackee.etherkit.tests"), network: .rinkeby, path: [])

    func testFuncWithZeroParameters() {
        let testZeroParametersExpectation = expectation(description: "Zero Parameters")
        etherQueryMock.testContract(at: testContractAddress).testViewFunc().send(using: key).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testZeroParametersExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testPayableCallSucceeds() {
        let testPayableCallExpectation = expectation(description: "Payable Call")
        etherQueryMock.testContract(at: testContractAddress).testBool(trueOrFalse: false).send(using: key, amount: Wei(1)).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testPayableCallExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testNonPayableCallSucceeds() {
        let testnonPayableCallExpectation = expectation(description: "Nonpayable Call")
        etherQueryMock.testContract(at: testContractAddress).testBool(trueOrFalse: false).send(using: key, amount: Wei(1)).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testnonPayableCallExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

}

class EtherQueryMock: EtherQuerying {
    func send<T: PrivateKeyType> (
        using key: T,
        to: Address,
        value: UInt256,
        data: GeneralData? = nil,
        queue: DispatchQueue = DispatchQueue.global(qos: .default),
        completion: @escaping (Result<Hash, EtherKitError>) -> Void) {
        let hash = Hash(data: Data("Ether hash".utf8))
        completion(Result(value: hash))
    }
}

extension EtherQueryMock {
    func testContract(at: Address) -> TestContractBox {
        return TestContractBox(etherQuery: self, at: at)
    }
}
