//
// Created by Erik Little on 4/3/18.
//

import Foundation
import Kit

/// The game of The Builders.
public struct TheBuildersRules : GameRules {
    /// What a turn looks like in this game. A turn consists of a set of phases that are executed in order.
    public let turn: [Phase] = []

    private var moveCount = 0

    public init() {

    }

    /// Executes player's turn.
    ///
    /// - parameter forPLayer: The player whose turn it is.
    public mutating func executeTurn(forPlayer player: Player) {
        print("It's \(player.id)'s turn")
        moveCount += 1
    }

    /// Calculates whether or not this game is over, based on some criteria.
    ///
    /// - parameter context: The context these rules are applying to.
    /// - returns: `true` if this game is over, false otherwise.
    public func isGameOver(_ context: GameContext) -> Bool {
        return moveCount >= 999
    }

    /// Starts a game. This is called to deal cards, give money, etc, before the first player goes.
    ///
    /// - parameter withContext: The context these rules are applying to.
    public mutating func startGame(withContext context: GameContext) {

    }
}
