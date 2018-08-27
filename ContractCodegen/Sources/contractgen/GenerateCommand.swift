import Foundation
import SwiftCLI
import ContractCodegenFramework
import PathKit
import StencilSwiftKit
import Stencil

// TODO: Limit number of words for contract to only one
class GenerateCommand: SwiftCLI.Command {

    let name = "generate"
    let shortDescription = "Generates Swift code for contract"

    let contractName = Parameter(completion: .none)
    let file = Parameter(completion: .filename)
    // TODO: Add another parameter for output directory (or Flag ... ?)

    func execute() throws {
        let arguments = CommandLine.arguments


        let filePath = Path.current + Path(arguments[2])
        guard filePath.exists else {
            stdout <<< "File at given path does not exist."
            return
        }

        let contractHeaders: [ABIElement]

        do {
            let abiData: Data = try filePath.read()
            contractHeaders = try JSONDecoder().decode([ABIElement].self, from: abiData)
        } catch {
            // TODO: handle error
            stdout <<< "Error!"
            return
        }

        let funcs: [Function] = contractHeaders.compactMap {
            switch $0 {
            case .function(let f): return f
            case .event(_): return nil
            }
        }

        // TODO: Add events

        // TODO: Add to real project
        // let swiftCodeURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/" + "contract.swift")
        let swiftCodePath = Path("/Users/marekfort/Development/ackee/EthereumProjectTemplate_copy/Skeleton/contract.swift")

        let stencilSwiftExtension = Extension()
        stencilSwiftExtension.registerStencilSwiftExtensions()
        let fsLoader = FileSystemLoader(paths: ["templates/"])
        let environment = Environment(loader: fsLoader, extensions: [stencilSwiftExtension])
        let functionsDictArray = funcs.map {["name": $0.name, "params": $0.inputs.map { $0.renderToSwift() }.joined(separator: ", "), "callingParams": $0.inputs.map { "\($0.name): \\(\($0.name))" }.joined(separator: ", "), "paramsDict": $0.inputs.map { "\"\($0.name)\": \"\\(\($0.name))\"" }.joined(separator: ", ")]}
        let context: [String: Any] = ["contractName": contractName.value, "lowercasedContractName": contractName.value.lowercased() "functions": functionsDictArray]

        do {
            let rendered = try environment.renderTemplate(name: "contractgen.stencil", context: context)
            stdout <<< rendered
            try swiftCodePath.write(rendered)
            stdout <<< "✅"
        } catch {
            stdout <<< "Write Error!"
            return
        }
    }
}
