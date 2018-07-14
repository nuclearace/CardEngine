//
// Created by Erik Little on 4/9/18.
//

import Foundation
import Kit
import NIO

// Internal helpers for Builders

infix operator ~~> : PhasePrecedenceGroup

precedencegroup PhasePrecedenceGroup {
    associativity: left
}

// MARK: Errors

/// Errors that can occur during a game
enum BuildersError : Error {
    /// A bad hand was played
    case badPlay

    /// The game has gone and died.
    case gameDeath
}

public typealias BuildersHand = Hand<BuildersPlayable>
