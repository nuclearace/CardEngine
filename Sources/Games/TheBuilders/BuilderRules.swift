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

    /// Executes a turn.
    public mutating func executeTurn() -> EventLoopFuture<()> {
        #if DEBUG
        print("\(context.activePlayer.id)'s turn")
        #endif

        moveCount += 1

        return StartPhase(context: context)
                ~~> CountPhase(context: context)
                ~~> DealPhase(context: context)
                ~~> DrawPhase(context: context)
                ~~> BuildPhase(context: context)
                ~~> EndPhase(context: context)
    }

    /// Calculates whether or not this game is over, returning the winning players.
    ///
    /// - returns: An array of `BuilderPlayer` who've won, or an empty array if no one has one.
    public func getWinners() -> [BuilderPlayer] {
        return context.hotels.filter({ $0.value.floorsBuilt > 0 }).map({ $0.key })
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
            case _:
                player.hand.append(Material.getInstance())
            }
        }
    }
}
