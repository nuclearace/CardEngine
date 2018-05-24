//
// Created by Erik Little on 5/24/18.
//

import Foundation

/// The set of events that can happen during a Builders game.
public enum BuilderEvent : String {
    /// Sent when the server has a message that should be shown.
    case dialog

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
