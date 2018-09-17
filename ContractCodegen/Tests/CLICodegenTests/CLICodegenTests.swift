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
}
