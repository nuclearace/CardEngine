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

    /// Call when there is enough players in the wait queue to start a new game.
    func startGame()
}

final class DefaultLobby<Game: GameContext> : GameLobby where Game.RulesType.PlayerType: InteractablePlayer {
    typealias GameType = Game

    var games = [UUID: GameType]()

    var waitingPlayers = [WsPlayer]()

    private let lock = DispatchSemaphore(value: 1)

    func addPlayerToWait(_ player: WebSocket) {
        defer { lock.signal() }

        lock.wait()

        guard !waitingPlayers.contains(where: { player === $0.0 }) else { return }

        let loop = MultiThreadedEventLoopGroup.currentEventLoop!

        // unowned(unsafe) is safe here since lobbies should be global to the program, but we don't want ARC overhead
        player.onClose.do {[weak player, unowned(unsafe) self] in
            guard let player = player else { return }

            self.lock.wait()
            self.waitingPlayers = self.waitingPlayers.filter({ $0.ws !== player })
            self.lock.signal()
        }.catch {_ in }

        if waitingPlayers.count >= 1 {
            print("Should start a game")
            waitingPlayers.append((player, loop))
            startGame()
        } else {
            print("add to wait queue")
            waitingPlayers.append((player, loop))
        }
    }

    func removeGame(_ game: GameType) {
        lock.wait()
        games[game.id] = nil
        lock.signal()
    }

    func startGame() {
        guard waitingPlayers.count >= 2 else {
            fatalError("Something went wrong, we should have two players waiting to start a game")
        }

        let board = GameType(runLoop: group.next())
        let players = [
            GameType.RulesType.PlayerType(context: board,
                                          interfacer: WebSocketInterfacer(ws: waitingPlayers[0].ws,
                                                                          game:  board,
                                                                          onLoop: waitingPlayers[0].loop)),
            GameType.RulesType.PlayerType(context: board,
                                          interfacer: WebSocketInterfacer(ws: waitingPlayers[1].ws,
                                                                          game: board,
                                                                          onLoop: waitingPlayers[1].loop))
        ]

        board.setupPlayers(players)
        board.startGame()

        games[board.id] = board
        waitingPlayers = Array(waitingPlayers.dropFirst(2))
    }
}
