//
// Created by Erik Little on 4/3/18.
//

import Foundation

/// Represents the playing area for a game. This contains the context for the entire game.
public final class Board : GameContext {
    /// The player who is currently making moves
    public var activePlayer: Player

    /// The players in this game.
    public private(set) var players: [Player]

    /// What a turn looks like in this context.
    public private(set) var rules: GameRules

    /// Creates a new game with the given players.
    public init(players: [Player], rules: GameRules) {
        assert(players.count >= 2, "You need more players for this game!")

        self.players = players
        self.activePlayer = players.first!
        self.rules = rules
    }

    /// Starts this game.
    public func startGame() {
        while !rules.isGameOver(self) {
            rules.executeTurn(forPlayer: activePlayer)

            (players, activePlayer) = (Array(players[1...]) + [activePlayer], players[1])
        }
    }
}
