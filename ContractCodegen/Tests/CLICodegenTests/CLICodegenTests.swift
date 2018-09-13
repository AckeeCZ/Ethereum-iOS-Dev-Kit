import Foundation
import XCTest
import PathKit
import SwiftCLI

class CommandLineToolTests: XCTestCase {

    private func runContractgen() throws {
        let task = Task(executable: ".build/debug/contractgen", arguments: ["TestContract", "abi.json"])
        task.runSync()
        try Path("GeneratedContracts").delete()
    }

    func testGeneratedContractsFileCreated() throws {
        try runContractgen()

        XCTAssertTrue(Path("GeneratedContracts").exists)

        try Path("GeneratedContracts").delete()
    }

    func testTestContractFileCreated() throws {
        try runContractgen()

        XCTAssertTrue(Path("GeneratedContracts/TestContract.swift").exists)

        try Path("GeneratedContracts").delete()
    }

    func testSharedContractFileCreated() throws {
        try runContractgen()

        XCTAssertTrue(Path("GeneratedContracts/SharedContract.swift").exists)

        try Path("GeneratedContracts").delete()
    }
}
