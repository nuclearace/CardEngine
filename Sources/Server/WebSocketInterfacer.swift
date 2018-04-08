//
// Created by Erik Little on 4/8/18.
//

import Foundation
import NIO
import Kit
import WebSocket

class WebSocketInterfacer : UserInterfacer {
    private(set) var responsePromise: EventLoopPromise<String>?

    let ws: WebSocket

    init(ws: WebSocket) {
        self.ws = ws

        // Now that they're in a game, all input should be considered as fulfilling a promise.
        self.ws.onText {[weak self] text in
            guard let this = self else { return }

            this.responsePromise?.succeed(result: text)
        }
    }

    deinit {
        print("Some WebSocketInterfacer is dying")
    }

    func send(_ str: String) {
        ws.send(str)
    }

    func getInput(withDialog dialog: String, withPromise promise: EventLoopPromise<String>) {
        responsePromise = promise

        ws.send(dialog)
    }
}

