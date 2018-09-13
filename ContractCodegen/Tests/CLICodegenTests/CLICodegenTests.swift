import Foundation
import XCTest
import PathKit
import SwiftCLI

class CommandLineToolTests: XCTestCase {

    private let generatedContractsString = "GeneratedContracts"

    private func runContractgen(output: String = "", xcode: String = "") throws {
        let task = Task(executable: ".build/debug/contractgen", arguments: ["TestContract", "abi.json", output, xcode])
        task.runSync()
        try Path(generatedContractsString).delete()
    }

    func testGeneratedContractsFileCreated() throws {
        try runContractgen()

        XCTAssertTrue(Path("GeneratedContracts").exists)

        try Path("GeneratedContracts").delete()
    }

    func testTestContractFileCreated() throws {
        try runContractgen()

        XCTAssertTrue(Path(generatedContractsString + "/TestContract.swift").exists)

        try Path("GeneratedContracts").delete()
    }

    func testSharedContractFileCreated() throws {
        try runContractgen()

        XCTAssertTrue(Path(generatedContractsString + "/SharedContract.swift").exists)

        try Path(generatedContractsString).delete()
    }

    func testOutputOption() throws {
        let outputPath = "Output/" + generatedContractsString
        try runContractgen(output: outputPath)

        XCTAssertTrue(Path(outputPath).exists)
        XCTAssertTrue(Path(outputPath + "/SharedContract.swift").exists)
        XCTAssertTrue(Path(outputPath + "/TestContract.swift").exists)

        try Path(outputPath).delete()
    }

}
