//
// Created by Erik Little on 4/3/18.
//

import Foundation
import Kit


/// A hand of BuildersPlayables
internal typealias BuilderHand = [BuildersPlayable]

/// Represents a playable item in the The Builders.
public protocol BuildersPlayable : Playable {
    /// The type of this playable.
    var playType: BuildersPlayType { get }
}

/// Represents the types of playables.
public enum BuildersPlayType {
    /// A material playable. These are used to construct parts of the structure.
    case material

    /// A worker playable. These control whether or not you can build.
    case worker

    /// An accident playable. These cards affect the status of the game. Such as injuring workers or causing strikes.
    case accident
}

