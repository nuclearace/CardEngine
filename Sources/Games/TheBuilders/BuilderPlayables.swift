//
// Created by Erik Little on 4/3/18.
//

import Foundation
import Kit

/// Represents a playable item in the The Builders.
public protocol BuildersPlayable : Playable, Encodable {
    /// The type of this playable.
    var playType: BuildersPlayType { get }

    // TODO this should probably be defined on `Playable` but that needs associated types setup
    /// Returns whether or not this playable can be played by player.
    ///
    /// - parameter inContext: The context this playable is being used in.
    /// - parameter byPlayer: The player playing.
    func canPlay(inContext context: BuildersBoard, byPlayer player: BuilderPlayer) -> Bool
}

/// Represents the types of playables.
public enum BuildersPlayType : String, Encodable {
    /// A material playable. These are used to construct parts of the structure.
    case material

    /// A worker playable. These control whether or not you can build.
    case worker

    /// An accident playable. These cards affect the status of the game. Such as injuring workers or causing strikes.
    case accident
}

/// A hand of BuildersPlayables
internal typealias BuildersHand = [BuildersPlayable]

struct EncodableHand : Encodable {
    var hand: [BuildersPlayable]

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        for playable in hand {
            try playable.encode(to: container.superEncoder())
        }
    }
}

extension Array where Element == BuildersPlayable {
    var accidents: [Accident] {
        return map({ $0 as? Accident }).compactMap({ $0 })
    }

    var workers: [Worker] {
        return map({ $0 as? Worker }).compactMap({ $0 })
    }

    var materials: [Material] {
        return map({ $0 as? Material }).compactMap({ $0 })
    }

    func prettyPrinted() -> String {
        return enumerated().map({ "\($0.offset + 1): \($0.element)\n" }).joined()
    }
}

