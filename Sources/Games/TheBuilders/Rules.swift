//
// Created by Erik Little on 4/3/18.
//

import Foundation
import NIO
import Kit

/// The game of The Builders.
public struct BuildersRules : GameRules {
    static let cardsNeededInHand = 7

    /// The context these rules are applying to
    public unowned let context: BuildersBoard

    private var moveCount = 0

    public init(context: BuildersBoard) {
        self.context = context
    }

    /// Executes player's turn.
    ///
    /// - parameter forPLayer: The player whose turn it is.
    public mutating func executeTurn(forPlayer player: BuilderPlayer) -> EventLoopFuture<()> {
        print("\(player.id)'s turn")

        moveCount += 1

        return CountPhase(context: context)
                ~~> DealPhase(context: context)
                ~~> DrawPhase(context: context)
                ~~> BuildPhase(context: context)
                ~~> EndPhase(context: context)
    }

    /// Calculates whether or not this game is over, based on some criteria.
    ///
    /// - returns: `true` if this game is over, false otherwise.
    public func isGameOver() -> Bool {
        return context.hotels.map({ $0.value.floorsBuilt }).reduce(0, +) > 0
    }

    /// Starts a game. This is called to deal cards, give money, etc, before the first player goes.
    public mutating func setupGame() {
        // Every player gets 2 workers and 5 material to start a game.
        for player in context.players {
            fillHand(ofPlayer: player)
        }
    }

    private func fillHand(ofPlayer player: BuilderPlayer) {
        for i in 0..<BuildersRules.cardsNeededInHand {
            switch i {
            case 0...1:
                player.hand.append(Worker.getInstance())
            default:
                player.hand.append(Material.getInstance())
            }
        }
    }
}

// MARK: Errors

/// Errors that can occur during a game
enum BuildersError : Error {
    /// A bad hand was played
    case badPlay

    /// The game has gone and died.
    case gameDeath
}
