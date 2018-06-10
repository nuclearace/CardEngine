//
// Created by Erik Little on 5/27/18.
//

import Foundation
import Kit

/// An interaction with a Builders player.
public struct BuildersInteraction : Encodable {
    /// The name of this phase of a turn.
    public var phase: BuildersPlayerPhaseName?

    /// Any text that should be displayed to the player.
    public var dialog: [String]?

    /// The winners of this game.
    public var winners: [String]?

    /// This player's hand.
    public var hand: [BuildersPlayable]?

    // TODO docstring
    public init(phase: BuildersPlayerPhaseName? = nil,
                dialog: [String]? = nil,
                winners: [String]? = nil,
                hand: [BuildersPlayable]? = nil) {
        self.phase = phase
        self.dialog = dialog
        self.winners = winners
        self.hand = hand
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if let phase = self.phase {
            try container.encode(phase, forKey: .phase)
        }

        if let dialog = self.dialog {
            try container.encode(dialog, forKey: .dialog)
        }

        if let winners = self.winners {
            try container.encode(winners, forKey: .winners)
        }

        if let hand = self.hand {
            try container.encode(EncodableHand(hand: hand), forKey: .hand)
        }
    }

    private enum CodingKeys : CodingKey {
        case phase, dialog, winners, hand
    }
}

/// Represents a response from a player.
public enum BuildersPlayerResponse : Decodable {
    /// The player is discarding some cards. The payload is an array of Int that represents the +1 index of the card.
    case discard([Int])

    /// The player is drawing some cards. The payload is a `BuildersPlayType` that is to be drawn.
    case draw(BuildersPlayType)

    /// The player is playing some cards. The payload is an array of Int that represents the +1 index of the card.
    case play([Int])

    public init(from decoder: Decoder) throws {
        let con = try decoder.container(keyedBy: CodingKeys.self)

        if let discard = try? con.decode([Int].self, forKey: .discard) {
            self = .discard(discard)
        } else if let drawType = try? con.decode(BuildersPlayType.self, forKey: .draw) {
            self = .draw(drawType)
        } else if let played = try? con.decode([Int].self, forKey: .play) {
            self = .play(played)
        } else {
            throw ResponseError.badInput
        }
    }

    private enum CodingKeys : CodingKey {
        case discard, draw, play
    }

    enum ResponseError : Error {
        case badInput
    }
}
