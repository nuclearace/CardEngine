//
// Created by Erik Little on 4/3/18.
//

import Foundation

/// Represents the rules of a game. This consists of what a turn looks like in the game, as well as determining when a
/// game is over.
public protocol GameRules {
    // MARK: Typealiases

    associatedtype TurnReturnType

    /// The type of the context for these rules. Constrained to prevent mixing and matching Rules/Players/etc
    associatedtype ContextType: GameContext where ContextType.RulesType == Self

    /// The type of the player for these rules. Constrained to prevent mixing and matching Rules/Players/etc
    associatedtype PlayerType: Player where PlayerType.RulesType == Self

    // MARK: Properties

    /// The context these rules apply in.
    var context: ContextType { get }

    // MARK: Methods

    /// Executes a turn. Depending on the game, this might involve just one player, or many.
    mutating func executeTurn() -> TurnReturnType

    /// Calculates whether or not this game is over, returning the winning players.
    ///
    /// - returns: An array of `PlayerType` who've won, or an empty array if no one has one.
    func getWinners() -> [PlayerType]

    /// Setups a game. This is called to deal cards, give money, etc, before the first player goes.
    mutating func setupGame()
}

