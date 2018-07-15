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

public typealias BuildersHand = Hand<BuildersPlayable>
