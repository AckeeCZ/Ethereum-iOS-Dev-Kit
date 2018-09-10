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

    private weak var imageView: UIImageView!
    private weak var activityIndicator: UIActivityIndicatorView!
    private weak var reloadButton: UIButton!

//    private var generatedKey: HDKey.Private! {
//        didSet {
//            generatedKey.unlocked(queue: DispatchQueue.main) {
//                self.addressField.text = $0.value?.publicKey.address.description
//            }
//        }
//    }

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

        //afaik etherkit cant import wallets (e.g. by mnemonic), but can generate new wallets.
        //upon reinstalling the app, call keyManager.createKeyPair. Write down the public address like below.
        //etherKit will be able to lookup the privateKey for this address in the keychain and sign transactions with it.
        //to make transactions from this address, you need some ether.
        //request it from the rinkeby faucet by following https://gist.github.com/cryptogoth/10a98e8078cfd69f7ca892ddbdcf26bc
        let myAddress = try! Address(describing: "0x7cA5E6a3200A758B146C17D4E3a4E47937e79Af5")

//        let toAddress = try! Address(describing: "0x3D4771895210E5f54A9bF88B1F20308659B0A40b")

        //      query.send(using: keyManager, from: myAddress, to: toAddress, value: UInt256(0x131c00000000000)) { result in
        //        switch result {
        //        case let .failure(error):
        //          self.showError(error.localizedDescription)
        //        case let .success(value):
        //          print(value)
        //        }
        //      }
        query.request(query.balanceOf(myAddress)) { [weak self] balanceResult in
            guard let `self` = self else { assertionFailure(); return }
            switch balanceResult {
            case let .failure(error):
                self.showError(error.localizedDescription)
            case let .success(balance):
                print("--------------")
                print(balance)
            }
        }

        let sentence: Mnemonic.MnemonicSentence = Mnemonic.MnemonicSentence(["truly", "law", "tide", "pony", "media", "degree", "two", "goat", "ignore", "twice", "project", "message", "vanish", "spring", "movie"])

        let walletStorage = KeychainStorageStrategy(identifier: "cz.ackee.etherkit.example")
        _ = walletStorage.delete()
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
                            print(key.publicKey.address)
//                            self.myAddress = key.publicKey.address
                        }
                    }
            }
        }

        let key = HDKey.Private(walletStorage, network: .rinkeby, path: [
            KeyPathNode(at: 44, hardened: true),
            KeyPathNode(at: 60, hardened: true),
            KeyPathNode(at: 0, hardened: true),
            KeyPathNode(at: 0),
        ])

//        HDKey.Private.create(with: .english, mnemonic: Mnemonic.MnemonicSentence(["this is a sentence"]), network: network, path: , completion: )
//          keyManager.createKeyPair { [weak self] addressResult in
//            guard let `self` = self else { assertionFailure(); return }
//            switch addressResult {
//            case let .failure(error):
//              self.showError(error.localizedDescription)
//            case let .success(address):
//              print("--------------")
//              print(address)
//
//            }
//          }

        // I have a HelloWorld contract running at this address, it has the following ABI:
        // [ { "constant": true, "inputs": [ { "name": "message", "type": "string" } ], "name": "say", "outputs": [ { "name": "result", "type": "string", "value": "" } ], "payable": false, "stateMutability": "pure", "type": "function" }, { "inputs": [], "payable": false, "stateMutability": "nonpayable", "type": "constructor" } ]
        // We want to be able to call its "say" function with a String parameter. It should return a String.
        let helloWorldContractAddress = try! Address(describing: "0x8652cF5536867EA8024EadA6eB0801c7A698772b")
//        query.greeterContract(at: helloWorldContractAddress).greet(greet_string: "Hi").send(using: keyManager, from: myAddress, amount: UInt256(0x131c00000000000)).startWithResult { result in
//            print(result)
//            switch result {
//            case .success(let hash):
//                print(hash)
//                print("Succeeded!")
//            case .failure(let error):
//                print(error)
//                print("Error :(((")
//            }
//        }

        query.greeterContract(at: helloWorldContractAddress).foo(bar: "bar").send(using: key, amount: UInt256(0x0)).startWithResult { result in
            switch result {
            case .success(let hash):
                print(hash)
                print("Succeeded with foo!")
            case .failure(let error):
                print(error)
                print("Error foo :(((")
            }
        }
//        query.send(using: keyManager, from: myAddress, to: toAddress, value: UInt256(0x131c00000000000), data: sayHiData) { result in
//            switch result {
//            case let .failure(error):
//                self.showError(error.localizedDescription)
//            case let .success(value):
//                print(value)
//            }
//        }

        //      query.sayHi(using: keyManager, from: myAddress, to: helloWorldContractAddress, value: UInt256(0x100000000000000)) { result in
        //          print(result)
        //      }

    }

//    let keyManager = EtherKeyManager(applicationTag: "cz.ackee.etherkit.example")

    let query = EtherQuery(URL(string: "https://geth-infrastruktura-master.ack.ee")!, connectionMode: .http)
    //    URL(string: "http://localhost:8545")!,

    // MARK: Helpers

    private func setupBindings() {

        activityIndicator.reactive.isAnimating <~ viewModel.actions.fetchPhoto.isExecuting

        viewModel.actions.fetchPhoto <~ reloadButton.reactive.controlEvents(.touchUpInside).map { _ in }

        imageView.reactive.image <~ viewModel.photo

    }

}

// This is a basic example. We will want to find a nicer API for this. Im thinking, nest function of each contract inside its own namespace, i.e:
// let producer: SignalProducer<Value, EtherKitError> = etherKit.helloWorldContract.sayHi(sender:to:value:parameters:),
// where parameters is a tuple of parameters of the function and Value is the return type
// Maybe even explore something like etherKit.helloWorldContract(at:/*ContractAddressHere*/).sayHi(.....)

/*extension EtherQuery {
 public func sayHi(
 using keyManager: EtherKeyManager,
 from sender: Address,
 to: Address,
 value: UInt256,
 completion: @escaping (Result<Hash, EtherKitError>) -> Void
 ) {
 request(
 networkVersion(),
 transactionCount(sender, blockNumber: .pending)
 ) { result in
 switch result {
 case let .success(items):

 let (network, nonce) = items

 /*keyManager.sign(
 with: sender,
 transaction: TransactionCall(
 nonce: UInt256(nonce.describing),
 to: to,
 gasLimit: UInt256(22000),
 // 21000 is the current base value for any transaction (e.g. just sending ether)
 // if the transaction includes data, it needs more gat depending on how many bytes are used
 // see https://ethereum.stackexchange.com/questions/1570/mist-what-does-intrinsic-gas-too-low-mean
 // TODO: calculate and use the right ammount of gas
 // TODO: find out how this value changes overtime, maybe EtherKit shouldnt be hardcoding the 21000 constant
 //            gasLimit: UInt256(21000),
 gasPrice: UInt256(20_000_000_000),
 value: value
 // TODO: pass serialized function selector and parameters
 // Currently we'd have to serialize the function selector and argument as per https://github.com/ethereum/wiki/wiki/Ethereum-Contract-ABI
 // Im hoping to get EtherKit to support this for us (https://github.com/Vaultio/EtherKit/issues/19)
 //            data: try! GeneralData.value(from: contractFunctionNameAndParams)
 ),
 network: network
 ) {
 switch $0 {
 case let .success(signedTransaction):
 let encodedData = RLPData.encode(from: signedTransaction)
 let sendRequest = SendRawTransactionRequest(SendRawTransactionRequest.Parameters(data: encodedData))
 self.request(sendRequest) { completion($0) }
 case let .failure(error):
 completion(.failure(error))
 }
 }*/
 case let .failure(error):
 completion(.failure(error))
 }
 }
 }
 }*/

extension UIViewController {
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}

