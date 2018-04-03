//
// Created by Erik Little on 4/3/18.
//

import Foundation

/// Represents the playing area for a game. This contains the context for the entire game.
public final class Board : GameContext {
    /// The players in this game.
    public let players: [Player]

    /// What a turn looks like in this context.
    public let rules: GameRules

    /// The player who is currently making moves
    public var activePlayer: Player

    /// Creates a new game with the given players.
    public init(players: [Player], rules: GameRules) {
        assert(!players.isEmpty, "You can't have a game with no players!")

        self.players = players
        self.activePlayer = players.first!
        self.rules = rules
    }
}

/// Represents the state of a game.
public protocol GameContext {
    /// The player who is currently making moves
    var activePlayer: Player { get set }

    /// The players in this game.
    var players: [Player] { get }

    /// What a turn looks like in this context.
    var rules: GameRules { get }
}
