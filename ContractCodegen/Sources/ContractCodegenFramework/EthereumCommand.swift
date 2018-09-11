import Foundation

public protocol EthereumCommand: Command {
    static func send(rawTransaction data: Data, onSuccess: @escaping (EtherHash) -> Message) -> Self
}
