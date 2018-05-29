//
// Created by Erik Little on 4/8/18.
//

import Foundation
import Dispatch
import HTTP
import NIO
import Kit
import Vapor
import WebSocket

// Import the games
import TheBuilders

let ws = HTTPServer.webSocketUpgrader(shouldUpgrade: {_ in [:] }, onUpgrade: handleUpgrade)

private func handleUpgrade(_ websocket: WebSocket, _ request: HTTPRequest) {
    websocket.onText {websocket, string in
        guard let maybeJson = try? JSONSerialization.jsonObject(with: string.data(using: .utf8)!),
              let json = maybeJson as? [String: Any] else {
            websocket.close()

            return
        }

        guard let game = json["game"] as? String else {
            websocket.close()

            return
        }

        switch game {
        case BuildersBoard.name:
            Lobbies.buildersLobby.addPlayerToWait(websocket)
        case _:
            return
        }
    }
}

func gameStopped<T: GameContext>(_ game: T) {
    switch game {
    case let game as BuildersBoard:
        Lobbies.buildersLobby.removeGame(game)
    case _:
        return
    }
}
