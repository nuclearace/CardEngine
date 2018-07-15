//
// Created by Erik Little on 4/3/18.
//

import Foundation
import NIO
import Kit

/// Represents the playing area for a game. This contains the context for the entire game.
public final class BuildersBoard : GameContext {
    public typealias RulesType = BuildersRules

    /// The name of this game.
    public static let name = "TheBuilders"

    /// This context's event loop. Used to submit work that needs to be run on that loop.
    public let runLoop: EventLoop

    /// The player who is currently making moves
    public var activePlayer: RulesType.PlayerType {
        return players[activePlayerIndex]
    }

    /// The id for this game.
    public let id = UUID()

    /// The state of the board.
    public internal(set) var state: BuildersBoardState!

    /// The players in this game.
    public private(set) var players = [RulesType.PlayerType]()

    /// What a turn looks like in this context.
    public private(set) var rules: RulesType!

    private var activePlayerIndex = 0

    /// Creates a new game that operates on the given run loop.
    public init(runLoop: EventLoop) {
        self.runLoop = runLoop
        self.state = BuildersBoardState(context: self)
        self.rules = BuildersRules(context: self)
    }

    #if DEBUG
    deinit {
        print("Game{\(id)} is dying")
    }
    #endif

    private func announceWinners(_ winners: [BuilderPlayer]) {
        // TODO Use some kind of name for the players
        let buildersInteraction = BuildersInteraction(
            gameState: BuildersState(floorsBuilt: state.hotels.byPlayerId(mappingValues: { $0.floorsBuilt })),
            winners: winners.map({ $0.id.uuidString })
        )
        let interaction = UserInteraction(type: .gameOver, interaction: buildersInteraction)

        for player in players {
            player.send(interaction)
        }
    }

    @discardableResult
    private func nextTurn() -> EventLoopFuture<()> {
        let winners = rules.getWinners()

        guard winners.isEmpty else {
            announceWinners(winners)

            return runLoop.newSucceededFuture(result: ())
        }

        return rules.executeTurn().then {[weak self] stateChange -> EventLoopFuture<()> in
            guard let this = self else { return deadGame() }

            this.state = stateChange
            this.setupNextPlayer()

            return this.nextTurn()
        }.thenIfError {[weak self] error in
            guard let this = self else { return deadGame() }

            switch error {
            case let builderError as GameError where builderError == .gameDeath:
                return deadGame()
            case let builderError as GameError where builderError == .badPlay:
                fallthrough
            case is BuildersPlayerResponse.ResponseError:
                return this.nextTurn()
            case _:
                fatalError("Unknown error \(error)")
            }
        }
    }

    private func setupNextPlayer() {
        activePlayerIndex = (activePlayerIndex + 1) % players.count
    }

    /// Sets up this game with players.
    ///
    /// - parameter players: The players.
    private func setupPlayers(_ players: [RulesType.PlayerType]) {
        assert(players.count >= 2, "You need more players for this game!")

        self.players = players

        for player in players {
            state.hotels[player] = Hotel()
            state.cardsInPlay[player] = []
            state.cardsInHand[player] = []
        }
    }

    /// Starts this game.
    public func startGame(withPlayers players: [RulesType.PlayerType]) {
        runLoop.execute {
            self.setupPlayers(players)
            self.rules.setupGame()

            for player in self.players {
                let interaction = BuildersInteraction(gameState: BuildersState(id: player.id.uuidString))
                player.send(UserInteraction(type: .gameStart, interaction: interaction))
            }

            #if DEBUG
            print("start first turn")
            #endif
            self.nextTurn()
        }
    }

    public func stopGame() {
        runLoop.execute {
            for player in self.players {
                player.interfacer.responsePromise?.fail(error: GameError.gameDeath)
            }
        }
    }
}
