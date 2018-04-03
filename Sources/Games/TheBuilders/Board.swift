//
// Created by Erik Little on 4/3/18.
//

import Foundation
import Kit

/// Represents the playing area for a game. This contains the context for the entire game.
public final class BuildersBoard : GameContext {
    public typealias GameType = TheBuildersRules

    /// The player who is currently making moves
    public var activePlayer: GameType.PlayerType

    /// The players in this game.
    public private(set) var players: [GameType.PlayerType]

    /// What a turn looks like in this context.
    public private(set) var rules: GameType!

    /// Creates a new game with the given players.
    public init(players: [GameType.PlayerType]) {
        assert(players.count >= 2, "You need more players for this game!")

        self.players = players
        self.activePlayer = players.first!
        self.rules = TheBuildersRules(context: self)
    }

    /// Starts this game.
    public func startGame() {
        while !rules.isGameOver() {
            rules.executeTurn(forPlayer: activePlayer)

            (players, activePlayer) = (Array(players[1...]) + [activePlayer], players[1])
        }
    }
}