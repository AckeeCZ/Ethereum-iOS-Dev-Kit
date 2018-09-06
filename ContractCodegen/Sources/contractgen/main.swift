#!/usr/bin/swift

import Foundation
import SwiftCLI
import ContractCodegenFramework

let generatorCLI = CLI(singleCommand: GenerateCommand())

let generator = ZshCompletionGenerator(cli: generatorCLI)
generator.writeCompletions()

generatorCLI.goAndExit()
