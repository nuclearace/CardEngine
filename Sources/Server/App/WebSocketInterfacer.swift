//
// Created by Erik Little on 4/8/18.
//

import Foundation
import NIO
import Kit
import WebSocket

/// A type for interacting with a user over a WebSocket.
final class WebSocketInterfacer<T: GameContext> : UserInterfacer {
    private(set) var responsePromise: EventLoopPromise<String>?

    weak var game: T!
    let ws: WebSocket
    let wsEventLoop: EventLoop

    private let id = UUID()

    init(ws: WebSocket, game: T, onLoop: EventLoop) {
        self.ws = ws
        self.game = game
        self.wsEventLoop = onLoop

        #if DEBUG
            print("Creating WebSocketInterfacer{\(id)}")
        #endif

        // Now that they're in a game, all input should be considered as fulfilling a promise.
        self.ws.onText {[weak self] websocket, text in
            guard let this = self else { return }

            this.responsePromise?.succeed(result: text)
        }

        // TODO(game-continuation)
        self.ws.onClose.do {_ in
            game.stopGame()
            removeGameFromLobby(game: game)
        }.catch {_ in }
    }

    #if DEBUG
    deinit {
        print("WebSocketInterfacer{\(id)} is dying")
    }
    #endif

    func send(_ str: String) {
        wsEventLoop.execute {
            #if DEBUG
                print("Send{\(self.id)}: \(str)")
            #endif

            self.ws.send(str)
        }
    }

    func getInput(withDialog dialog: String, withPromise promise: EventLoopPromise<String>) {
        wsEventLoop.execute {
            #if DEBUG
                print("Send{\(self.id)}: \(dialog)")
            #endif

            self.responsePromise = promise
            self.ws.send(dialog)
        }
    }
}

