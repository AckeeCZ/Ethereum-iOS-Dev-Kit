// Generated using ContractGen
// swiftlint:disable file_length

import ReactiveSwift
import EtherKit
import BigInt

struct GreeterContractBox {
    fileprivate let etherQuery: EtherQuery
    fileprivate let at: Address

    init(etherQuery: EtherQuery, at: Address) {
        self.etherQuery = etherQuery
        self.at = at
    }

    func setPrices<T: PrivateKeyType>(newSellPrice: BigUInt, newBuyPrice: BigUInt) -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let setPricesFunctionCall = Function(name: "setPrices", parameters: [newSellPrice, newBuyPrice])
                let setPricesData = GeneralData(data: setPricesFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: setPricesData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }

    func name<T: PrivateKeyType>() -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let nameFunctionCall = Function(name: "name", parameters: [])
                let nameData = GeneralData(data: nameFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: nameData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }

    func approve<T: PrivateKeyType>(spender: Address, value: BigUInt) -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let approveFunctionCall = Function(name: "approve", parameters: [spender, value])
                let approveData = GeneralData(data: approveFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: approveData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }

    func totalSupply<T: PrivateKeyType>() -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let totalSupplyFunctionCall = Function(name: "totalSupply", parameters: [])
                let totalSupplyData = GeneralData(data: totalSupplyFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: totalSupplyData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }

    func transferFrom<T: PrivateKeyType>(from: Address, to: Address, value: BigUInt) -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let transferFromFunctionCall = Function(name: "transferFrom", parameters: [from, to, value])
                let transferFromData = GeneralData(data: transferFromFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: transferFromData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }

    func decimals<T: PrivateKeyType>() -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let decimalsFunctionCall = Function(name: "decimals", parameters: [])
                let decimalsData = GeneralData(data: decimalsFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: decimalsData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }

    func burn<T: PrivateKeyType>(value: BigUInt) -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let burnFunctionCall = Function(name: "burn", parameters: [value])
                let burnData = GeneralData(data: burnFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: burnData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }

    func sellPrice<T: PrivateKeyType>() -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let sellPriceFunctionCall = Function(name: "sellPrice", parameters: [])
                let sellPriceData = GeneralData(data: sellPriceFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: sellPriceData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }

    func helloThree<T: PrivateKeyType>(uintArray: Array<BigUInt>) -> PayableContractMethodInvocation<T> {
        let send: (_ using: T, _ amount: Wei) -> SignalProducer<Hash, EtherKitError> = { using, amount in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let helloThreeFunctionCall = Function(name: "helloThree", parameters: [uintArray])
                let helloThreeData = GeneralData(data: helloThreeFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: amount, data: helloThreeData, completion: { result in
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
        return PayableContractMethodInvocation(send: send)
    }

    func helloIntEight<T: PrivateKeyType>(value: Int) -> PayableContractMethodInvocation<T> {
        let send: (_ using: T, _ amount: Wei) -> SignalProducer<Hash, EtherKitError> = { using, amount in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let helloIntEightFunctionCall = Function(name: "helloIntEight", parameters: [value])
                let helloIntEightData = GeneralData(data: helloIntEightFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: amount, data: helloIntEightData, completion: { result in
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
        return PayableContractMethodInvocation(send: send)
    }

    func mintToken<T: PrivateKeyType>(target: Address, mintedAmount: BigUInt) -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let mintTokenFunctionCall = Function(name: "mintToken", parameters: [target, mintedAmount])
                let mintTokenData = GeneralData(data: mintTokenFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: mintTokenData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }

    func burnFrom<T: PrivateKeyType>(from: Address, value: BigUInt) -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let burnFromFunctionCall = Function(name: "burnFrom", parameters: [from, value])
                let burnFromData = GeneralData(data: burnFromFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: burnFromData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }

    func helloFive<T: PrivateKeyType>(trueOrFalse: Bool) -> PayableContractMethodInvocation<T> {
        let send: (_ using: T, _ amount: Wei) -> SignalProducer<Hash, EtherKitError> = { using, amount in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let helloFiveFunctionCall = Function(name: "helloFive", parameters: [trueOrFalse])
                let helloFiveData = GeneralData(data: helloFiveFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: amount, data: helloFiveData, completion: { result in
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
        return PayableContractMethodInvocation(send: send)
    }

    func buyPrice<T: PrivateKeyType>() -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let buyPriceFunctionCall = Function(name: "buyPrice", parameters: [])
                let buyPriceData = GeneralData(data: buyPriceFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: buyPriceData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }

    func owner<T: PrivateKeyType>() -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let ownerFunctionCall = Function(name: "owner", parameters: [])
                let ownerData = GeneralData(data: ownerFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: ownerData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }

    func symbol<T: PrivateKeyType>() -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let symbolFunctionCall = Function(name: "symbol", parameters: [])
                let symbolData = GeneralData(data: symbolFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: symbolData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }

    func helloIntBig<T: PrivateKeyType>(value: BigInt) -> PayableContractMethodInvocation<T> {
        let send: (_ using: T, _ amount: Wei) -> SignalProducer<Hash, EtherKitError> = { using, amount in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let helloIntBigFunctionCall = Function(name: "helloIntBig", parameters: [value])
                let helloIntBigData = GeneralData(data: helloIntBigFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: amount, data: helloIntBigData, completion: { result in
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
        return PayableContractMethodInvocation(send: send)
    }

    func helloFour<T: PrivateKeyType>(bytesArray: Array<Data>) -> PayableContractMethodInvocation<T> {
        let send: (_ using: T, _ amount: Wei) -> SignalProducer<Hash, EtherKitError> = { using, amount in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let helloFourFunctionCall = Function(name: "helloFour", parameters: [bytesArray])
                let helloFourData = GeneralData(data: helloFourFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: amount, data: helloFourData, completion: { result in
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
        return PayableContractMethodInvocation(send: send)
    }

    func buy<T: PrivateKeyType>() -> PayableContractMethodInvocation<T> {
        let send: (_ using: T, _ amount: Wei) -> SignalProducer<Hash, EtherKitError> = { using, amount in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let buyFunctionCall = Function(name: "buy", parameters: [])
                let buyData = GeneralData(data: buyFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: amount, data: buyData, completion: { result in
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
        return PayableContractMethodInvocation(send: send)
    }

    func transfer<T: PrivateKeyType>(to: Address, value: BigUInt) -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let transferFunctionCall = Function(name: "transfer", parameters: [to, value])
                let transferData = GeneralData(data: transferFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: transferData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }

    func helloTwo<T: PrivateKeyType>(extraData: Data) -> PayableContractMethodInvocation<T> {
        let send: (_ using: T, _ amount: Wei) -> SignalProducer<Hash, EtherKitError> = { using, amount in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let helloTwoFunctionCall = Function(name: "helloTwo", parameters: [extraData])
                let helloTwoData = GeneralData(data: helloTwoFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: amount, data: helloTwoData, completion: { result in
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
        return PayableContractMethodInvocation(send: send)
    }

    func approveAndCall<T: PrivateKeyType>(spender: Address, value: BigUInt, extraData: Data) -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let approveAndCallFunctionCall = Function(name: "approveAndCall", parameters: [spender, value, extraData])
                let approveAndCallData = GeneralData(data: approveAndCallFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: approveAndCallData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }

    func hello<T: PrivateKeyType>(decimalUnits: UInt) -> PayableContractMethodInvocation<T> {
        let send: (_ using: T, _ amount: Wei) -> SignalProducer<Hash, EtherKitError> = { using, amount in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let helloFunctionCall = Function(name: "hello", parameters: [decimalUnits])
                let helloData = GeneralData(data: helloFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: amount, data: helloData, completion: { result in
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
        return PayableContractMethodInvocation(send: send)
    }

    func sell<T: PrivateKeyType>(amountToSend: BigUInt) -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let sellFunctionCall = Function(name: "sell", parameters: [amountToSend])
                let sellData = GeneralData(data: sellFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: sellData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }

    func freezeAccount<T: PrivateKeyType>(target: Address, freeze: Bool) -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let freezeAccountFunctionCall = Function(name: "freezeAccount", parameters: [target, freeze])
                let freezeAccountData = GeneralData(data: freezeAccountFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: freezeAccountData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }

    func greet<T: PrivateKeyType>(greetString: String) -> PayableContractMethodInvocation<T> {
        let send: (_ using: T, _ amount: Wei) -> SignalProducer<Hash, EtherKitError> = { using, amount in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let greetFunctionCall = Function(name: "greet", parameters: [greetString])
                let greetData = GeneralData(data: greetFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: amount, data: greetData, completion: { result in
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
        return PayableContractMethodInvocation(send: send)
    }

    func transferOwnership<T: PrivateKeyType>(newOwner: Address) -> ContractMethodInvocation<T> {
        let send: (_ using: T) -> SignalProducer<Hash, EtherKitError> = { using in
            return SignalProducer<Hash, EtherKitError> { observer, disposable in
                let transferOwnershipFunctionCall = Function(name: "transferOwnership", parameters: [newOwner])
                let transferOwnershipData = GeneralData(data: transferOwnershipFunctionCall.encodeToCall())
                self.etherQuery.send(using: using, to: self.at, value: Wei(0), data: transferOwnershipData, completion: { result in
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
        return ContractMethodInvocation(send: send)
    }
}

extension EtherQuery {
    func greeterContract(at: Address) -> GreeterContractBox {
        return GreeterContractBox(etherQuery: self, at: at)
    }
}
