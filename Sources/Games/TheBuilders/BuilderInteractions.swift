//
// Created by Erik Little on 5/27/18.
//

import Foundation
import Kit

/// An interaction with a Builders player.
public struct BuildersInteraction : Encodable {
    private enum CodingKeys : CodingKey {
        case phase, dialog, winners, hand
    }

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
}


