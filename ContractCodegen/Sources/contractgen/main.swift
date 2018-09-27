#!/usr/bin/swift

import Foundation
import SwiftCLI
import ContractCodegenFramework

let generatorCLI = CLI(singleCommand: GenerateCommand())

generatorCLI.goAndExit()
