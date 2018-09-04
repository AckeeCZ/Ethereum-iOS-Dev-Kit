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
        } catch DecodingError.dataCorrupted(let context){
            print(context)
            stdout <<< "ABI JSON decode error! ⛔️"
            return
        }
        catch {
            stdout <<< "Other errrroooooor"
            return
        }

        let funcs: [Function] = contractHeaders.compactMap {
            switch $0 {
            case .function(let f): return f
            case .event(_): return nil
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
            print("rake \(xcodePath.absolute()) \(groupName) \(parentGroupName) \(swiftCodePath.absolute())")
            try run(bash: "rake -f /usr/local/share/contractgen/Rakefile \(xcodePath.absolute()) \(groupName) \(parentGroupName) \(swiftCodePath.absolute()) --tasks")
            stdout <<< "Code generation: ✅"
        } catch {
            stdout <<< "Rakefile error"
        }
    }
}
