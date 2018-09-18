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

    func testUint8() {
        let testUint8Expectation = expectation(description: "Uint8")
        etherQueryMock.testContract(at: testContractAddress).testUint8(decimalUnits: 1).send(using: key, amount: Wei(1)).startWithResult { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testUint8Expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
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
