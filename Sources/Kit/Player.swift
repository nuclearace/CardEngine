//
// Created by Erik Little on 4/3/18.
//

import Foundation

/// Represents a user.
public final class Player {
    /// The unique identifier for this player.
    public let id = UUID()

    /// This players hand.
    public private(set) var cards = [Playable]()

    public init () { }
}

extension Player : Hashable {
    public var hashValue: Int {
        return id.hashValue
    }

    public static func ==(lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
}
