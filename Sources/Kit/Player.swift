//
// Created by Erik Little on 4/3/18.
//

import Foundation

/// Represents a user.
public protocol Player : AnyObject, Hashable {
    /// The unique identifier for this player.
    var id: UUID { get }
}

extension Player {
    public var hashValue: Int {
        return id.hashValue
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
