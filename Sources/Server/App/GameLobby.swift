//
// Created by Erik Little on 5/1/18.
//

import Dispatch
import Foundation
import Kit
import NIO
import WebSocket

typealias WsPlayer = (ws: WebSocket, loop: EventLoop)

/// Marks a type will hold a set of games.
protocol GameLobby {
    /// The type of the game this lobby is for.
    associatedtype GameType: GameContext

    /// The games, indexed by a hash for the game.
    var games: [UUID: GameType] { get set }

    // TODO Handle players in game lobbies
    // TODO Better type for this
    /// The players who are waiting to join this game.
    var waitingPlayers: [WsPlayer] { get set }

    /// Adds a player to this lobby.
    func addPlayerToWait(_ player: WebSocket)

    /// Removes `game` from `games`.
    func removeGame(_ game: GameType)
}

final class DefaultLobby<Game: GameContext> : GameLobby where Game.RulesType.PlayerType: InteractablePlayer {
    typealias GameType = Game

    var games = [UUID: GameType]()

    var waitingPlayers = [WsPlayer]()

    private let runLoop = MultiThreadedEventLoopGroup.currentEventLoop!

    /// Adds a player to this lobby.
    func addPlayerToWait(_ player: WebSocket) {
        let loop = MultiThreadedEventLoopGroup.currentEventLoop!

        runLoop.execute {
            self.addPlayerToWait((player, loop))
        }
    }

    private func addPlayerToWait(_ player: WsPlayer) {
        guard !waitingPlayers.contains(where: { player.ws === $0.0 }) else { return }

        // unowned(unsafe) is safe here since lobbies should be global to the program, but we don't want ARC overhead
        player.ws.onClose.do {[unowned(unsafe) self] in
            self.runLoop.execute {
                self.waitingPlayers = self.waitingPlayers.filter({ $0.ws !== player.ws })
            }
        }.catch {_ in }

        if waitingPlayers.count >= 1 {
            #if DEBUG
            print("Should start a game")
            #endif
            waitingPlayers.append(player)
            startNewGame()
        } else {
            #if DEBUG
            print("add to wait queue")
            #endif
            waitingPlayers.append(player)
        }
    }

    /// Removes `game` from `games`.
    func removeGame(_ game: GameType) {
        runLoop.execute {
            self.games[game.id] = nil
        }
    }

    /// Call when there is enough players in the wait queue to start a new game.
    private func startNewGame() {
        precondition(waitingPlayers.count >= 2, "Should have two players waiting to start a game")

        let board = GameType(runLoop: runLoop)
        let players = [
            GameType.RulesType.PlayerType(context: board,
                                          interfacer: WebSocketInterfacer(ws: waitingPlayers[0].ws,
                                                                          game: board,
                                                                          onLoop: waitingPlayers[0].loop)),
            GameType.RulesType.PlayerType(context: board,
                                          interfacer: WebSocketInterfacer(ws: waitingPlayers[1].ws,
                                                                          game: board,
                                                                          onLoop: waitingPlayers[1].loop))
        ]

        board.startGame(withPlayers: players)

        games[board.id] = board
        waitingPlayers = Array(waitingPlayers.dropFirst(2))
    }
}
