import Foundation

protocol HasEtherViewModelFactory {
    var exampleVMFactory: () -> EtherViewModeling { get }
}

extension AppDependency: HasEtherViewModelFactory {
    var exampleVMFactory: () -> EtherViewModeling { return { EtherViewModel(dependencies: dependencies) } }
}
