//
// Created by Erik Little on 7/18/18.
//

import Foundation
import Kit
import WebSocket

import TheBuilders
import TicTacToe

func addWebSocketToGameLobby(gameName name: String, websocket ws: WebSocket) {
    switch name {
    case BuildersBoard.name:
        Lobbies.buildersLobby.addPlayerToWait(ws)
    case TTTGrid.name:
        Lobbies.ticTacToeLobby.addPlayerToWait(ws)
    case _:
        ws.send("bad payload")
        ws.close()
        return
    }
}

func removeGameFromLobby<T: GameContext>(game game: T) {
    switch game {
    case let game as BuildersBoard:
        Lobbies.buildersLobby.removeGame(game)
    case let game as TTTGrid:
        Lobbies.ticTacToeLobby.removeGame(game)
    case _:
        fatalError("Game type not handled in gameStopped")
    }
}
