//
// Created by Erik Little on 4/3/18.
//

import Foundation
import Kit

/// Represents a playable item in the The Builders.
public protocol BuildersPlayable : Playable, Encodable {
    /// The type of this playable.
    var playType: BuildersPlayType { get }

    /// The id of this playable.
    var id: UUID { get }

    // TODO this should probably be defined on `Playable` but that needs associated types setup
    /// Returns whether or not this playable can be played by player.
    ///
    /// - parameter inContext: The context this playable is being used in.
    /// - parameter byPlayer: The player playing.
    func canPlay(inContext context: BuildersBoard, byPlayer player: BuilderPlayer) -> Bool
}

// TODO whenever Swift allows generalizied existentials, we can directly conform BuildersPlayable to hashable
func == (lhs: BuildersPlayable, rhs: BuildersPlayable) -> Bool {
    return lhs.id == rhs.id
}

/// Represents the types of playables.
public enum BuildersPlayType : String, Codable {
    /// A material playable. These are used to construct parts of the structure.
    case material

    /// A worker playable. These control whether or not you can build.
    case worker

    /// An accident playable. These cards affect the status of the game. Such as injuring workers or causing strikes.
    case accident
}

/// A hand of BuildersPlayables
internal typealias BuildersHand = [BuildersPlayable]

/// A type that allows an array of arbitrary `BuildersPlayable`'s to to encoded.
struct EncodableHand : Encodable {
    var hand: [BuildersPlayable]

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        for playable in hand.displaySorted() {
            try playable.encode(to: container.superEncoder())
        }
    }
}

extension Array where Element == BuildersPlayable {
    var accidents: [Accident] {
        return compactMap({ $0 as? Accident })
    }

    var workers: [Worker] {
        return compactMap({ $0 as? Worker })
    }

    var materials: [Material] {
        return compactMap({ $0 as? Material })
    }

    func prettyPrinted() -> String {
        return enumerated().map({ "\($0.offset + 1): \($0.element)\n" }).joined()
    }

    /// Sorts the player's hand in an order that makes the most sense to be displayed:
    /// 1. Workers
    /// 2. Material
    /// 3. Accidents
    ///
    /// - returns: The hand sorted in the display order.
    func displaySorted() -> [BuildersPlayable] {
        return self.sorted(by: {first, second in
            switch first.playType {
            case .worker:
                return true
            case .material where second.playType != .worker:
                return true
            case _:
                return false
            }
        })
    }
}

