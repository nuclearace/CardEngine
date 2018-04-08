//
// Created by Erik Little on 4/8/18.
//

import Foundation
import NIO
import Kit

/// A interfacer for testing purposes.
struct ConsoleInterfacer : UserInterfacer {
    private(set) var responsePromise: EventLoopPromise<String>?

    func send(_ str: String) {
        print(str)
    }

    func getInput(withDialog dialog: String, withPromise promise: EventLoopPromise<String>) {
        print(dialog)

        promise.succeed(result: readLine(strippingNewline: true) ?? "")
    }
}
