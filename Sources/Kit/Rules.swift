//
// Created by Erik Little on 4/3/18.
//

import Foundation

/// Phases represent different parts of a turn. During a phase different actions can be taken.
public protocol Phase {
    /// Run this phase with the given context.
    ///
    /// - parameter withContext: The context with which to execute in.
    mutating func executePhase(withContext context: GameContext)
}

/// Represents the rules of a game. This consists of what a turn looks like in the game, as well as
public protocol GameRules {
    /// What a turn looks like in this game. A turn consists of a set of phases that are executed in order.
    var turn: [Phase] { get }

    /// Calculates whether or not this game is over, based on some criteria.
    ///
    /// - parameter context: The context these rules are applying to.
    /// - returns: `true` if this game is over, false otherwise.
    func isGameOver(_ context: GameContext) -> Bool
}
