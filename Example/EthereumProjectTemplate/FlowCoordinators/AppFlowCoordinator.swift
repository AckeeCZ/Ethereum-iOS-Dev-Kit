import UIKit
import ACKategories

final class AppFlowCoordinator: FlowCoordinator {

    override func start(in window: UIWindow) {
        super.start(in: window)

        let vm = EtherViewModel(dependencies: dependencies)
        let vc = EtherViewController(viewModel: vm)

        window.rootViewController = vc

        rootViewController = vc
    }
}
