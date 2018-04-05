//
// Created by Erik Little on 4/3/18.
//

import Foundation
import Kit

/// Represents the playing area for a game. This contains the context for the entire game.
public final class BuildersBoard : GameContext {
    public typealias RulesType = BuildersRules

    /// The player who is currently making moves
    public var activePlayer: RulesType.PlayerType

    // TODO This is a bit crappy. Eventually we'll probably have another object that encapsulates this state
    /// The cards that are currently in play.
    public internal(set) var cardsInPlay = [RulesType.PlayerType: [BuildersPlayable]]()

    /// The players in this game.
    public private(set) var players: [RulesType.PlayerType]

    /// What a turn looks like in this context.
    public private(set) var rules: RulesType!

    /// Creates a new game with the given players.
    public init(players: [RulesType.PlayerType]) {
        assert(players.count >= 2, "You need more players for this game!")

        self.players = players
        self.activePlayer = players.first!
        self.rules = BuildersRules(context: self)
    }

    /// Starts this game.
    public func startGame() {
        rules.setupGame()

        while !rules.isGameOver() {
            rules.executeTurn(forPlayer: activePlayer)

            (players, activePlayer) = (Array(players[1...]) + [activePlayer], players[1])
        }
    }
}
