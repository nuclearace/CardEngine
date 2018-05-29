//
// Created by Erik Little on 4/2/18.
//

import Foundation

/// Represents a playable item in the game.
public protocol Playable {
    // MARK: Properties

    /// Creates a random instance of this playable.
    static func getInstance() -> Self
}
