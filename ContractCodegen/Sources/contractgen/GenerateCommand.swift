import Foundation
import SwiftCLI
import ContractCodegenFramework
import PathKit
import Stencil

class GenerateCommand: SwiftCLI.Command {

    let name = "generate"
    let shortDescription = "Generates Swift code for contract"

    let contractName = Parameter(completion: .none)
    let file = Parameter(completion: .filename)
    // TODO: Add second parameter for output directory (or Flag ... ?)

    func execute() throws {
        let arguments = CommandLine.arguments
        guard arguments.count == 3  else {
            // TODO: Ask user to enter a different name
            stdout <<< "Hello world!"
            fatalError()
        }

        let filePath = Path.current + Path(arguments[2])
        guard filePath.exists else {
            stdout <<< "File at given path does not exist."
            fatalError()
        }

        let contractHeaders: [ABIElement]

        do {
            let abiData: Data = try filePath.read()
            contractHeaders = try JSONDecoder().decode([ABIElement].self, from: abiData)
        } catch {
            // TODO: handle error
            stdout <<< "Error!"
            fatalError()
        }

        let funcs: [Function] = contractHeaders.compactMap {
            switch $0 {
            case .function(let f): return f
            case .event(_): return nil
            }
        }
        let renderedFuncs = funcs.map { $0.renderToSwift() }
        let protocolFuncDeclarations = renderedFuncs.map { "static " + $0 }.joined(separator: "\n")
        let protocolCode = renderedFuncs.reduce(
            // TODO: Can this string be better formatted for the alignment of the other code?
            """
            protocol \(contractName.value): EthereumCommand {
            \(protocolFuncDeclarations)
            }

            extension \(contractName.value) {\n
            """
        ) {
            $0 + "static " + $1 + """
            {
            guard let data = params.data(using: .utf8) else { fatalError() }
            Run.send(rawTransaction: data, onSuccess: { _ in })
            }
            """
            } + "\n}"

        // TODO: Add events to string here

        var extensionCode = """
        \n
        extension EtherQuery {
        func \(contractName.value)(at: String) -> EtherQuery {
        return self
        }
        """

        extensionCode += funcs.map { generateExtensionFuncString(with: $0) }.joined(separator: "\n")

        // TODO: Add to real project
        // let swiftCodeURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/" + "contract.swift")
        let swiftCodePath = Path("/Users/marekfort/Development/ackee/EthereumProjectTemplate_copy/Skeleton/contract.swift")

        let fsLoader = FileSystemLoader(paths: ["templates/"])
        let environment = Environment(loader: fsLoader)
        let context = ["contractName": contractName.value]

        do {
            let rendered = try environment.renderTemplate(name: "contractgen.stencilě", context: context)
            stdout <<< rendered
            try swiftCodePath.write(rendered)
            stdout <<< "✅"
        } catch {
            stdout <<< "Error!"
            fatalError()
        }
    }

    private func isFunction(_ element: ABIElement) -> Bool {
        switch element {
        case .function(_):
            return true
        case .event(_):
            return false
        }
    }

    private func generateFuncStringIfNecessary(with element: ABIElement) -> String {
        if isFunction(element) {
            return """
            {
            guard let data = params.data(using: .utf8) else { fatalError() }
            Run.send(rawTransaction: data, onSuccess: { _ in })
            }
            """
        } else {
            return ""
        }
    }

    private func generateExtensionFuncString(with function: Function) -> String {
        return """
        \nfunc \(function.name)(\(function.inputs.map { $0.renderToSwift() }.joined(separator: ", "))) -> (_ using: EtherKeyManager, _ from: Address, _ to: Address, _ amount: UInt256) -> SignalProducer<Hash, EtherKitError> {
            return { using, from, to, amount in
                return SignalProducer<Hash, EtherKitError> { observer, disposable in
        //pass the params representing calling this function in the proper format to etherkit
        guard let paramsData = "foo(bar: barrrrrrrrrrr".data(using: .utf8) else {
        observer.send(error: EtherKitError.web3Failure(reason: .parsingFailure))
        return
        }
        self.send(using: using, from: from, to: to, value: amount, data: GeneralData(data: paramsData), completion: { result in
        switch result {
        case .success(let hash):
        observer.send(value: hash)
        case .failure(let error):
        observer.send(error: error)
        observer.sendCompleted()
        }
        })
        }
        }
        }
        }
        """
    }
}
