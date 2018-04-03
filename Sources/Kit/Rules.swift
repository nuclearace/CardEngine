//
// Created by Erik Little on 4/3/18.
//

import Foundation

/// Phases represent different parts of a turn. During a phase different actions can be taken.
public protocol Phase {
    /// The type of rules this phase applies to.
    associatedtype RulesType: GameRules

    /// Run this phase with the given context.
    ///
    /// - parameter withContext: The context with which to execute in.
    mutating func executePhase(withContext context: RulesType.ContextType)
}

/// Represents the rules of a game. This consists of what a turn looks like in the game, as well as determining when a
/// game is over.
public protocol GameRules {
    associatedtype ContextType: GameContext where ContextType.RulesType == Self
    associatedtype PhaseType: Phase
    associatedtype PlayerType: Player

    /// The context these rules apply in.
    var context: ContextType { get set }

    /// What a turn looks like in this game. A turn consists of a set of phases that are executed in order.
    var turn: [PhaseType] { get }

    /// Executes player's turn.
    ///
    /// - parameter forPLayer: The player whose turn it is.
    mutating func executeTurn(forPlayer player: PlayerType)

    /// Calculates whether or not this game is over, based on some criteria.
    ///
    /// - returns: `true` if this game is over, false otherwise.
    func isGameOver() -> Bool

    /// Starts a game. This is called to deal cards, give money, etc, before the first player goes.
    mutating func startGame()
}
