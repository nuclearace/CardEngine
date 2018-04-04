//
// Created by Erik Little on 4/3/18.
//

import Foundation
import Kit

public final class BuilderPlayer : Player {
    public let id = UUID()

    /// The playable items that this player has. This are items that are not in play.
    public internal(set) var hand = [BuildersPlayable]() {
        willSet {
            precondition(hand.count <= 6, "A player should not have more than 7 playables in their at any time")
        }
    }

    public init () {}
}
