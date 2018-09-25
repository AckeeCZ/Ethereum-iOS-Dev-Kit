// Generated using ContractGen

import ReactiveSwift
import EtherKit
import BigInt
import Result

typealias Wei = UInt256

struct PayableContractMethodInvocation<T: PrivateKeyType> {
    private let send: (_ using: T, _ amount: Wei) -> SignalProducer<Hash, EtherKitError>

    init(send: @escaping (_ using: T, _ amount: Wei) -> SignalProducer<Hash, EtherKitError>) {
        self.send = send
    }

    func send(using: T, amount: Wei) -> SignalProducer<Hash, EtherKitError> {
        return self.send(using, amount)
    }
}

struct ContractMethodInvocation<T: PrivateKeyType> {
    private let send: (_ using: T) -> SignalProducer<Hash, EtherKitError>

    init(send: @escaping (_ using: T) -> SignalProducer<Hash, EtherKitError>) {
        self.send = send
    }

    func send(using: T) -> SignalProducer<Hash, EtherKitError> {
        return self.send(using)
    }
}

// The code below is here for unit testing our dev kit
extension EtherQuery: EtherQuerying {}

protocol EtherQuerying {
    func send<T: PrivateKeyType> (
    using key: T,
    to: Address,
    value: UInt256,
    data: GeneralData?,
    queue: DispatchQueue,
    completion: @escaping (Result<Hash, EtherKitError>) -> Void)
}

