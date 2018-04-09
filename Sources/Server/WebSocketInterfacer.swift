//
// Created by Erik Little on 4/8/18.
//

import Foundation
import Games
import NIO
import Kit
import WebSocket

class WebSocketInterfacer<T: GameContext> : UserInterfacer {
    private(set) var responsePromise: EventLoopPromise<String>?

    weak var game: T!
    let ws: WebSocket

    init(ws: WebSocket, game: T) {
        self.ws = ws
        self.game = game

        // Now that they're in a game, all input should be considered as fulfilling a promise.
        self.ws.onText {[weak self] text in
            guard let this = self else { return }

            this.responsePromise?.succeed(result: text)
        }

        self.ws.onClose {
            game.stopGame()
            gameStopped(game: game)
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

