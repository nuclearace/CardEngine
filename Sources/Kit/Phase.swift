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

/// A turn represents a set of phases that are executed in order per player.
public struct Turn {
    /// The phases of this turn.
    public var phases: [Phase]
}
