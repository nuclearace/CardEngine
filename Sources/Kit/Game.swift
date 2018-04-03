//
// Created by Erik Little on 4/2/18.
//

import Foundation

/// Represents the state of a game.
public protocol GameContext : AnyObject {
    /// The type of game this context is playing.
    associatedtype RulesType : GameRules where RulesType.ContextType == Self

    /// The player who is currently making moves
    var activePlayer: RulesType.PlayerType { get set }

    /// The players in this game.
    var players: [RulesType.PlayerType] { get }

    /// The rules for the game executing in this context.
    var rules: RulesType! { get }

    /// Starts this game.
    func startGame()
}
