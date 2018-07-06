//
// Created by Erik Little on 7/5/18.
//

import Foundation

/// Represents the state of the board.
public struct BuildersBoardState {
    weak var context: BuildersBoard?

    /// The accidents that are afflicting a user.
    public internal(set) var accidents = [BuilderPlayer: [Accident]]()

    /// The cards that are currently in players' hands.
    public internal(set) var cardsInHand = [BuilderPlayer: BuildersHand]()

    /// The cards that are currently in play.
    public internal(set) var cardsInPlay = [BuilderPlayer: BuildersHand]()

    /// Each player's hotel.
    public internal(set) var hotels = [BuilderPlayer: Hotel]()

    init(context: BuildersBoard) {
        self.context = context
    }
}
