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
    let testContractAddress = try! Address(describing: "0x82C2977575313bC332390d8512b17A752a991270")
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
    
}
