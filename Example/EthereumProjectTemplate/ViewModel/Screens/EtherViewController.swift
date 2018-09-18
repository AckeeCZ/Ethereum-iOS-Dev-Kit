//
//  EtherViewController.swift
//  EthereumProjectTemplate
//
//  Created by Jan Misar on 28.08.18.
//  
//

import UIKit
import SnapKit
import ReactiveSwift
import EtherKit
import Result
import BigInt

// MARK: notes
// - EtherKit is still in development. Currently its unusable in production.
// - The service Infura.io provides an ethereum node accessible over https, We can use the API Key EcrxWYU15S7Yu5vJNDzX , e.g access the Ropsten testnet using the url https://ropsten.infura.io/EcrxWYU15S7Yu5vJNDzX
//    Unfortunatelly, Infura doesnt adhere to the JSONRPC spec (doesnt support String id's), so it cant be used with the current version of EtherKit
// - We can work against a local ethereum node, run e.g. `geth --testnet --rpc --rpcaddr "127.0.0.1" --rpcport "8545" console`, then access it at http://localhost:8545
//    I couldnt get it to work over https, so NSAppTransportSecurity/NSAllowsArbitraryLoads has been set in the info.plist for now

// - EtherKit known issues:
//   - When using EtherKit over http, geth seems to require Content-Type application/json header (else returns 415). Edit URLRequestManager.swift queueRequest method to add the header (we should make a PR into EtherKit)
//   - EtherKit.request method has an error callback, but if an error occurs,
//      it gets lost in the underlying URLRequestManager and the callback is never called
//   - There are more potential places where a method's callback might not get called.
// MARK: -----------

final class EtherViewController: BaseViewController {

    let query = EtherQuery(URL(string: "https://rinkeby.infura.io/v3/9f1a1e0782ab40c8b39fe189615714d0")!, connectionMode: .http)

    private weak var imageView: UIImageView!
    private weak var activityIndicator: UIActivityIndicatorView!
    private weak var reloadButton: UIButton!

    // MARK: Dependencies

    private let viewModel: EtherViewModeling

    // MARK: Initializers

    init(viewModel: EtherViewModeling) {
        self.viewModel = viewModel

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View life cycle

    override func loadView() {
        super.loadView()

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(imageView.snp.width)
        }
        self.imageView = imageView

        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.tintColor = .black
        activityIndicator.hidesWhenStopped = true
        imageView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        self.activityIndicator = activityIndicator

        let reloadButton = UIButton()
        reloadButton.setTitle("Reload", for: [])
        reloadButton.setTitleColor(.black, for: [])
        view.addSubview(reloadButton)
        reloadButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        self.reloadButton = reloadButton
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBindings()

        query.request(query.networkVersion()) {
            print($0)
        }

        // Use your own mnemonic sentence
        let sentence: Mnemonic.MnemonicSentence = Mnemonic.MnemonicSentence(["truly", "law", "tide", "pony", "media", "degree", "two", "goat", "ignore", "twice", "project", "message", "vanish", "spring", "movie"])
        let walletStorage = KeychainStorageStrategy(identifier: "cz.ackee.etherkit.example")
        HDKey.Private.create(
            with: MnemonicStorageStrategy(walletStorage),
            mnemonic: sentence,
            network: .main,
            path: [
                KeyPathNode(at: 44, hardened: true),
                KeyPathNode(at: 60, hardened: true),
                KeyPathNode(at: 0, hardened: true),
                KeyPathNode(at: 0),
                ]
        ) { _ in
            HDKey.Private(walletStorage, network: .main, path: [
                KeyPathNode(at: 44, hardened: true),
                KeyPathNode(at: 60, hardened: true),
                KeyPathNode(at: 0, hardened: true),
                KeyPathNode(at: 1),
                ]).unlocked { value in
                    DispatchQueue.main.async {
                        _ = value.map { key in
                            self.testContracts(with: key.publicKey.address)
                        }
                    }
            }
        }
    }

    private func testContracts(with myAddress: Address) {
        let walletStorage = KeychainStorageStrategy(identifier: "cz.ackee.etherkit.example")
        let key = HDKey.Private(walletStorage, network: .rinkeby, path: [
            KeyPathNode(at: 44, hardened: true),
            KeyPathNode(at: 60, hardened: true),
            KeyPathNode(at: 0, hardened: true),
            KeyPathNode(at: 1),
            ])

        let testContractAddress = try! Address(describing: "0xb8f016F3529b198b4a06574f3E9BDc04948ad852")
        query.testContract(at: testContractAddress).testBool(trueOrFalse: true).send(using: key, amount: Wei(1)).startWithResult { result in
            switch result {
            case .success(let hash):
                print(hash)
                print("Succeeded!")
            case .failure(let error):
                print(error)
                print("Error!")
            }
        }
    }

    // MARK: Helpers

    private func setupBindings() {

        activityIndicator.reactive.isAnimating <~ viewModel.actions.fetchPhoto.isExecuting

        viewModel.actions.fetchPhoto <~ reloadButton.reactive.controlEvents(.touchUpInside).map { _ in }

        imageView.reactive.image <~ viewModel.photo

    }
}

extension UIViewController {
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}

