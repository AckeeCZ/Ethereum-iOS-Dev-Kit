import Foundation

public struct Run<Message>: Command {
    public typealias Context = EtherKit
    //    public static var empty: Run<Action> { return Run { _ in }}
    //
    //    public static func <> (lhs: Run<Message>, rhs: Run<Message>) -> Run<Action> {
    //        return Run { callback in
    //            lhs.run(callback)
    //            rhs.run(callback)
    //        }
    //    }

    public let run: (_ context: Context, _ callback: @escaping (Message) -> ()) -> ()
    public init(run: @escaping (Context, @escaping (Message) -> ()) -> ()) {
        self.run = run
    }
}

extension Run: EthereumCommand {
    public static func send(rawTransaction data: Data, onSuccess: @escaping (Hash) -> Message) -> Run<Message> {
        return Run { etherKit, callback in
            etherKit.send(rawTransaction: data) { callback(onSuccess($0)) }
        }
    }
}

// TODO: Mock for now
public struct Hash { let value: String }
public class EtherKit {
    func send(rawTransaction data: Data, completion: (Hash) -> ()) {
        print("sending transaction")
        print("--------------------")
        print(data)
        print("--------------------")
        completion(Hash(value: "zhulenejHash"))
    }
}
