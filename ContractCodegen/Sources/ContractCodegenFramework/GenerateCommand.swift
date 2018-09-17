import Foundation
import SwiftCLI
import PathKit
import StencilSwiftKit
import Stencil

open class GenerateCommand: SwiftCLI.Command {

    public let name = "generate"
    public let shortDescription = "Generates Swift code for contract"

    let contractName = Parameter(completion: .none)
    let file = Parameter(completion: .filename)
    let output = Key<String>("-o", "--output", description: "Define output directory")
    let xcode = Key<String>("-x", "--xcode", description: "Define location of .xcodeproj")

    public init() {

    }

    public func execute() throws {

        let filePath = Path.current + Path(file.value)
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

        var projectPath: Path?
        if let projectPathValue = xcode.value {
            projectPath = Path(projectPathValue)
        }

        var generatedSwiftCodePath: Path?

        if let outputValue = output.value {
            if let xcodePath = xcode.value {
                var xcodeComponents = xcodePath.components(separatedBy: "/")
                xcodeComponents.remove(at: xcodeComponents.endIndex - 1)
                generatedSwiftCodePath = Path(xcodeComponents.joined(separator: "/")) + Path(outputValue)
            } else {
                generatedSwiftCodePath = Path(outputValue)
            }
        }

        writeGeneratedCode(to: generatedSwiftCodePath, funcs: funcs)

        // Do not bind files when project or swift code path is not given
        guard let xcodePath = projectPath, let swiftCodePath = generatedSwiftCodePath, let relativePathValue = output.value else { return }
        bindFilesWithProject(xcodePath: xcodePath, swiftCodePath: swiftCodePath, relativePathValue: relativePathValue)
    }

    /// Writes and renders code from .stencil files to a given directory
    private func writeGeneratedCode(to path: Path?, funcs: [Function]) {

        let swiftCodePath = path ?? (Path.current + Path("GeneratedContracts"))

        let stencilSwiftExtension = Extension()
        stencilSwiftExtension.registerStencilSwiftExtensions()
        // TODO: Is there a more suitable place?
        let fsLoader: FileSystemLoader
        if Path("../templates").exists {
            fsLoader = FileSystemLoader(paths: ["../templates/"])
        } else {
            fsLoader = FileSystemLoader(paths: ["/usr/local/share/contractgen/templates/"])
        }

        let environment = Environment(loader: fsLoader, extensions: [stencilSwiftExtension])
        let functionsDictArray = funcs.map {["name": $0.name, "params": $0.inputs.map { $0.renderToSwift() }.joined(separator: ", "), "values": $0.inputs.map { $0.name }.joined(separator: ", "), "isPayable": $0.isPayable]}
        let context: [String: Any] = ["contractName": contractName.value, "functions": functionsDictArray]

        do {
            if !swiftCodePath.exists {
                try FileManager.default.createDirectory(atPath: "\(swiftCodePath.absolute())", withIntermediateDirectories: true, attributes: nil)
            }

            let commonRendered = try environment.renderTemplate(name: "shared_contractgen.stencil")
            let sharedSwiftCodePath = swiftCodePath + Path("SharedContract.swift")
            if sharedSwiftCodePath.exists {
                try sharedSwiftCodePath.delete()
            }
            try sharedSwiftCodePath.write(commonRendered)
            let rendered = try environment.renderTemplate(name: "contractgen.stencil", context: context)
            let contractCodePath = swiftCodePath + Path(contractName.value + ".swift")
            try contractCodePath.write(rendered)
        } catch {
            stdout <<< "Write Error! 😱"
            return
        }
    }

    func findTargetIndex(rakeFilePath: Path, targetsString: String) -> Int {
        let targets = targetsString.components(separatedBy: "\n")
        // Prints targets as a list so user can choose with which one they want to bind their files
        for (index, target) in targets.enumerated() {
            print("\(index + 1). " + target)
        }

        let index = Input.readInt(
            prompt: "Choose target for the generated contract code:",
            validation: { $0 > 0 && $0 <= targets.count },
            errorResponse: { input in
                self.stderr <<< "'\(input)' is invalid; must be a number between 1 and \(targets.count)"
            }
        )

        return index
    }

    /// Binds file references with project, adds files to target
    private func bindFilesWithProject(xcodePath: Path, swiftCodePath: Path, relativePathValue: String) {
        let separatedPath = "\(swiftCodePath.absolute())".components(separatedBy: "/")
        guard let groupName = separatedPath.last else {
            stdout <<< "Xcode path error"
            return
        }

        let targetsString: String
        let rakeFilePath: Path
        do {
            if Path("../Rakefile").exists {
                rakeFilePath = Path("../Rakefile")
            } else {
                rakeFilePath = Path("/usr/local/share/contractgen/Rakefile")
            }
            targetsString = try capture(bash: "rake -f \(rakeFilePath.absolute()) xcode:find_targets'[\(xcodePath.absolute())]'").stdout
        } catch {
            stdout <<< "Rakefile task find_targets failed 😥"
            return
        }

        let index = findTargetIndex(rakeFilePath: rakeFilePath, targetsString: targetsString)

        var relativePathComponents = relativePathValue.components(separatedBy: "/")
        relativePathComponents.remove(at: relativePathComponents.endIndex - 1)
        let relativePath = relativePathComponents.joined(separator: "/")
        do {
            try run(bash: "rake -f \(rakeFilePath.absolute()) xcode:add_files_to_group'[\(xcodePath.absolute()),\(swiftCodePath.absolute()),\(groupName),\(relativePath),\(index - 1)]'")
            stdout <<< "Code generation: ✅"
        } catch {
            stdout <<< "Rakefile task add_files_to_group failed 😥"
        }
    }
}
