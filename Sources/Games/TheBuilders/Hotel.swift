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

    // TODO The rules should determine the criteria for a floor being built
    // TODO This is great and all, you can't build a floor without workers, but you also need some material
    /// Calculates whether or not this player has built any new floors.
    ///
    /// This removes cards from `fromPlayedCards` that were used to build a floor.
    internal mutating func calculateNewFloors(fromPlayedCards cards: inout BuildersHand) {
        let numWorks = cards.map({ $0 is Worker }).reduce(0, { $0 + ($1 ? 1 : 0) })

        if numWorks >= 5 {
            floorsBuilt += 1
            cards = BuildersHand(cards.dropFirst(5))
        }
    }
}
