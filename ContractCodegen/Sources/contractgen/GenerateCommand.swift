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
    let output = Key<String>("-o", "--output", description: "Define output directory")
    let xcode = Key<String>("-x", "--xcode", description: "Define location of .xcodeproj")

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
            stdout <<< "ABI JSON decode error! ⛔️"
            return
        }

        let funcs: [Function] = contractHeaders.compactMap {
            switch $0 {
            case .function(let f): return f
            default: return nil
            }
        }

        // TODO: Add events
        let swiftCodePath: Path

        if let outputValue = output.value {
            swiftCodePath = Path(outputValue)
        } else {
            swiftCodePath = Path.current + Path("../GeneratedContracts")
        }


        let stencilSwiftExtension = Extension()
        stencilSwiftExtension.registerStencilSwiftExtensions()
        // TODO: Is there a more suitable place?
        let fsLoader = FileSystemLoader(paths: ["/usr/local/share/contractgen/templates/"])
        let environment = Environment(loader: fsLoader, extensions: [stencilSwiftExtension])
        let functionsDictArray = funcs.map {["name": $0.name, "params": $0.inputs.map { $0.renderToSwift() }.joined(separator: ", "), "values": $0.inputs.map { $0.name }.joined(separator: ", ")]}
        let context: [String: Any] = ["contractName": contractName.value, "functions": functionsDictArray]

        do {
            if !swiftCodePath.exists {
                try FileManager.default.createDirectory(atPath: "\(swiftCodePath.absolute())", withIntermediateDirectories: false, attributes: nil)
            }
            let commonRendered = try environment.renderTemplate(name: "shared_contractgen.stencil")
            let sharedSwiftCodePath = swiftCodePath + Path("SharedContract.swift")
            if sharedSwiftCodePath.exists {
                try sharedSwiftCodePath.delete()
            }
            try sharedSwiftCodePath.write(commonRendered)
            let rendered = try environment.renderTemplate(name: "contractgen.stencil", context: context)
            let contractCodePath = swiftCodePath + Path(arguments[1] + ".swift")
            try contractCodePath.write(rendered)
        } catch {
            stdout <<< "Write Error! 😱"
            return
        }

        let xcodePath: Path
        if let xcodeValue = xcode.value {
            xcodePath = Path(xcodeValue)
        } else {
            guard let path = Path.glob("../../*.xcodeproj").first else {
                stdout <<< "Could not find Xcode project! 😓"
                return
            }
            xcodePath = path
        }

        do {
            let separatedPath = "\(swiftCodePath.absolute())".components(separatedBy: "/")
            guard let groupName = separatedPath.last else {
                stdout <<< "Xcode path error"
                return
            }
            let parentGroupName = separatedPath[separatedPath.index(separatedPath.endIndex, offsetBy: -2)]

            let targetsString = try capture(bash: "rake -f /usr/local/share/contractgen/Rakefile find_targets \(xcodePath.absolute())").stdout
            let targets = targetsString.components(separatedBy: "\n")
            for (index, target) in targets.enumerated() {
                print("\(index + 1). " + target)
            }

            // - 1 to get index from 0
            let index = Input.readInt(
                prompt: "Choose target for the generated contract code:",
                validation: { $0 > 0 && $0 < targets.count },
                errorResponse: { input in
                    self.stderr <<< "'\(input)' is invalid; must be a number between 1 and \(targets.count)"
                }
            ) - 1

//            print("rake -f /usr/local/share/contractgen/Rakefile add_files_to_group \(xcodePath.absolute()) \(groupName) \(parentGroupName) \(swiftCodePath.absolute()) \(index)")
            try run(bash: "rake -f /usr/local/share/contractgen/Rakefile add_files_to_group \(xcodePath.absolute()) \(groupName) \(parentGroupName) \(swiftCodePath.absolute())")
            stdout <<< "Code generation: ✅"
        } catch {
            stdout <<< "Rakefile error"
        }
    }
}
