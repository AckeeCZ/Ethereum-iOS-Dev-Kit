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
        let swiftCodePath = Path.current + Path("../GeneratedContracts")

        let stencilSwiftExtension = Extension()
        stencilSwiftExtension.registerStencilSwiftExtensions()
        let fsLoader = FileSystemLoader(paths: ["templates/"])
        let environment = Environment(loader: fsLoader, extensions: [stencilSwiftExtension])
        let functionsDictArray = funcs.map {["name": $0.name, "params": $0.inputs.map { $0.renderToSwift() }.joined(separator: ", "), "parameterTypes": $0.inputs.map { $0.abiTypeString }.joined(separator: ", "), "values": $0.inputs.map { $0.name }.joined(separator: ", ")]}
        let context: [String: Any] = ["contractName": contractName.value, "functions": functionsDictArray]

        do {
            if !swiftCodePath.exists {
                try FileManager.default.createDirectory(atPath: "\(swiftCodePath.absolute())", withIntermediateDirectories: false, attributes: nil)
            }
            let commonRendered = try environment.renderTemplate(name: "shared_contractgen.stencil")
            let sharedSwiftCodePath = swiftCodePath + Path("SharedContract.swift")
            if !sharedSwiftCodePath.exists {
                try sharedSwiftCodePath.write(commonRendered)
            }
            let rendered = try environment.renderTemplate(name: "contractgen.stencil", context: context)
            let contractCodePath = swiftCodePath + Path(arguments[1] + ".swift")
            try contractCodePath.write(rendered)
            stdout <<< "Code generation: ✅"
        } catch {
            stdout <<< "Write Error! 😱"
            return
        }
    }
}
