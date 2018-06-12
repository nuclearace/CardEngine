//
// Created by Erik Little on 5/27/18.
//

import Foundation
import Kit

// TODO don't make this public
/// An interaction with a Builders player.
public struct BuildersInteraction : Encodable {
    /// The name of this phase of a turn.
    public var phase: BuildersPlayerPhaseName?

    /// Any text that should be displayed to the player.
    public var dialog: [String]?

    /// The state of a game.
    public var gameState: BuildersState?

    /// The winners of this game.
    public var winners: [String]?

    /// This player's hand.
    public var hand: [BuildersPlayable]?

    /// Creates a new `BuildersInteraction` with the given values. All parameters are optional.
    ///
    /// - parameter phase: What phase of a turn this interaction is for.
    /// - parameter dialog: Any text that should be shown to the user. This should be reserved for things the client
    ///                     couldn't know. Such as errors or events.
    /// - parameter gameState: The state of the game. See `BuildersState` for more details.
    /// - parameter winners: The winners of this game.
    /// - parameter hand: The player's hand.
    public init(
            phase: BuildersPlayerPhaseName? = nil,
            dialog: [String]? = nil,
            gameState: BuildersState? = nil,
            winners: [String]? = nil,
            hand: [BuildersPlayable]? = nil
    ) {
        self.phase = phase
        self.dialog = dialog
        self.gameState = gameState
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

        if let state = self.gameState {
            try container.encode(state, forKey: .gameState)
        }

        if let winners = self.winners {
            try container.encode(winners, forKey: .winners)
        }

        if let hand = self.hand {
            try container.encode(EncodableHand(hand: hand), forKey: .hand)
        }
    }

    private enum CodingKeys : CodingKey {
        case phase, dialog, gameState, winners, hand
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

/// Represents the state of a builders game
public struct BuildersState : Encodable {
    // TODO player names
    /// The cards that are currently in play.
    var cardsInPlay: [String: EncodableHand]

    /// The id of this player. This is only set during game start to allow the client to identify the player.
    var id: String? = nil

    init(cardsInPlay: [String: EncodableHand] = [:], id: String? = nil) {
        self.cardsInPlay = cardsInPlay
        self.id = id
    }
}
