//
// Created by Erik Little on 4/2/18.
//

import Foundation

/// Represents a playable item in the game.
public protocol Playable {
    /// The type of this playable.
    var playType: PlayType { get }

    /// Creates a random instance of this playable.
    static func getInstance() -> Self
}

/// Represents the types of playables.
public enum PlayType {
    /// A material playable. These are used to construct parts of the structure.
    case material

    /// A worker playable. These control whether or not you can build.
    case worker

    /// An accident playable. These cards affect the status of the game. Such as injuring workers or causing strikes.
    case accident
}

public extension Playable {
    /// An array of all known playables.
    public static var allPlayables: [Playable.Type] {
        return [Worker.self]
    }
}
