//
// Created by Erik Little on 4/3/18.
//

import Foundation

/// Represents the rules of a game. This consists of what a turn looks like in the game, as well as determining when a
/// game is over.
public protocol GameRules {
    associatedtype TurnReturnType

    /// The type of the context for these rules. Constrained to prevent mixing and matching Rules/Players/etc
    associatedtype ContextType: GameContext where ContextType.RulesType == Self

    /// The type of the player for these rules. Constrained to prevent mixing and matching Rules/Players/etc
    associatedtype PlayerType: Player where PlayerType.RulesType == Self

    /// The context these rules apply in.
    var context: ContextType { get }

    /// Executes player's turn.
    ///
    /// - parameter forPlayer: The player whose turn it is.
    mutating func executeTurn(forPlayer player: PlayerType) -> TurnReturnType

    /// Calculates whether or not this game is over, based on some criteria.
    ///
    /// - returns: `true` if this game is over, false otherwise.
    func isGameOver() -> Bool

    /// Setups a game. This is called to deal cards, give money, etc, before the first player goes.
    mutating func setupGame()
}

