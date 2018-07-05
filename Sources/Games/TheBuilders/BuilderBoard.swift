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

    /// The player who is currently making moves
    public var activePlayer: RulesType.PlayerType {
        return players[activePlayerIndex]
    }

    /// The id for this game.
    public let id = UUID()

    /// The accidents that are afflicting a user.
    public internal(set) var accidents = [RulesType.PlayerType: [Accident]]()

    // TODO This is a bit crappy. Eventually we'll probably have another object that encapsulates this state
    /// The cards that are currently in play.
    public internal(set) var cardsInPlay = [RulesType.PlayerType: BuildersHand]()

    /// Each player's hotel.
    public internal(set) var hotels = [RulesType.PlayerType: Hotel]()

    /// The players in this game.
    public private(set) var players = [RulesType.PlayerType]()

    /// What a turn looks like in this context.
    public private(set) var rules: RulesType!

    /// The run loop for this game.
    let runLoop: EventLoop

    private var activePlayerIndex = 0

    /// Creates a new game that operates on the given run loop.
    public init(runLoop: EventLoop) {
        self.runLoop = runLoop
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
            gameState: BuildersState(floorsBuilt: hotels.byPlayerId(mappingValues: { $0.floorsBuilt })),
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

        // TODO better rollback
        let oldHand = activePlayer.hand
        let inPlay = cardsInPlay[activePlayer, default: []]
        let oldAccidents = accidents

        return rules.executeTurn().then {[weak self] _ -> EventLoopFuture<()> in
            guard let this = self else { return deadGame() }

            this.setupNextPlayer()

            return this.nextTurn()
        }.thenIfError {[weak self] error in
            guard let this = self else { return deadGame() }

            func rollbackTurn() {
                // This wasn't a valid turn reset to a previous state
                let active = this.activePlayer

                this.accidents = oldAccidents
                this.cardsInPlay[active] = inPlay

                active.hand = oldHand
            }

            switch error {
            case let builderError as BuildersError where builderError == .gameDeath:
                return deadGame()
            case let builderError as BuildersError where builderError == .badPlay:
                fallthrough
            case is BuildersPlayerResponse.ResponseError:
                rollbackTurn()

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
    public func setupPlayers(_ players: [RulesType.PlayerType]) {
        assert(players.count >= 2, "You need more players for this game!")

        self.players = players
        self.hotels = players.reduce(into: [RulesType.PlayerType: Hotel](), {hotels, player in
            hotels[player] = Hotel()
        })
    }

    /// Starts this game.
    public func startGame() {
        runLoop.execute {
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
                player.interfacer.responsePromise?.fail(error: BuildersError.gameDeath)
            }
        }
    }
}
