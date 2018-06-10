//
// Created by Erik Little on 5/27/18.
//

import Foundation

/// Represents the top level message structure that goes from the server to a player.
///
/// Besides the `type`, the `interaction` is a generic type; the only thing it most conform to is `Encodable`.
/// This allows games to customize the API that they wish to have.
public struct UserInteraction<InteractionType: Encodable> : Encodable {
    // MARK: Properties

    /// The type of interaction this is.
    public var type: UserInteractionType

    /// Represents the interaction for this message. This can be anything that is `Encodable`.
    public var interaction: InteractionType

    // MARK: Initializers

    // TODO docstring
    public init(type: UserInteractionType, interaction: InteractionType) {
        self.type = type
        self.interaction = interaction
    }
}

/// The set of events that can happen during a game.
public enum UserInteractionType : String, Encodable {
    /// Sent when the server has a message that should be shown.
    case dialog

    /// Sent when the game starts.
    case gameStart

    /// The game has ended.
    case gameOver

    /// The player did something illegal.
    case playError

    /// Sent when a player starts their turn.
    case turnStart

    /// Sent during each part of a turn.
    case turn

    /// Sent when a player's turn is over.
    case turnEnd
}
