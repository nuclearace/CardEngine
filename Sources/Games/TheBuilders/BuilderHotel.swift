//
// Created by Erik Little on 4/5/18.
//

import Foundation
import Kit

/// The point of a game of Builders is for players to construct the best hotel in Pottersville.
///
/// This represents the hotel that the player is building.
///
/// A `Hotel` consists of a number floors. Each floor must have TODO number of cards a floor needs.
public struct Hotel {
    /// The number of floors that have been constructed.
    public private(set) var floorsBuilt = 0

    // TODO The rules should determine the criteria for a floor being built. So this should receive a context.
    /// Calculates whether or not this player has built any new floors.
    ///
    /// This removes cards from `fromPlayedCards` that were used to build a floor.
    internal mutating func calculateNewFloors(fromPlayedCards cards: inout BuildersHand) {
        // TODO do we need to check for workers? Or is that guarded during play and accident?
        var metal = false
        var wiring = false
        var insulation = false
        var glass = false

        for material in cards.materials {
            switch material.blockType {
            case .insulation:
                insulation = true
            case .glass:
                glass = true
            case .metal:
                metal = true
            case .wiring:
                wiring = true
            case .wood:
                // TODO wood and other score boosters
                continue
            }
        }

        // TODO nail down what is required
        if metal && insulation && glass && wiring {
            floorsBuilt += 1
            cards.removeAll()
        }
    }
}
