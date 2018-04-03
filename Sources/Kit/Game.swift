//
// Created by Erik Little on 4/2/18.
//

import Foundation

/// A namespace enum for various game related items.
public enum Game {
    /// An array of all known playables.
    public static var allPlayables: [Playable.Type] {
        return [Worker.self, Material.self]
    }
}

/// Represents the state of a game.
public protocol GameContext : AnyObject {
    /// The player who is currently making moves
    var activePlayer: Player { get set }

    /// The players in this game.
    var players: [Player] { get }

    /// What a turn looks like in this context.
    var rules: GameRules { get }

    /// Starts this game.
    func startGame()
}
