//
// Created by Erik Little on 4/2/18.
//

import Foundation

/// Represents the state of a game.
public protocol GameContext : AnyObject {
    /// The type of game this context is playing.
    associatedtype GameType: GameRules where GameType.ContextType == Self

    /// The player who is currently making moves
    var activePlayer: GameType.PlayerType { get set }

    /// The players in this game.
    var players: [GameType.PlayerType] { get }

    /// The rules for the game executing in this context.
    var rules: GameType! { get }

    /// Starts this game.
    func startGame()
}
