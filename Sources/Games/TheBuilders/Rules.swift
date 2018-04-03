//
// Created by Erik Little on 4/3/18.
//

import Foundation
import Kit

/// The game of The Builders.
public struct BuildersRules: GameRules {
    /// What a turn looks like in this game. A turn consists of a set of phases that are executed in order.
    public let turn = [DrawPhase(), DealPhase()]

    /// The context these rules are applying to
    public unowned let context: BuildersBoard

    private var moveCount = 0

    public init(context: BuildersBoard) {
        self.context = context
    }

    /// Executes player's turn.
    ///
    /// - parameter forPLayer: The player whose turn it is.
    public mutating func executeTurn(forPlayer player: BuilderPlayer) {
        for phase in turn {
            phase.executePhase(withContext: context)
        }

        moveCount += 1
    }

    /// Calculates whether or not this game is over, based on some criteria.
    ///
    /// - returns: `true` if this game is over, false otherwise.
    public func isGameOver() -> Bool {
        return moveCount >= 20
    }

    /// Starts a game. This is called to deal cards, give money, etc, before the first player goes.
    public mutating func startGame() {

    }
}

public class BuilderPhase: Phase {
    public typealias RulesType = BuildersRules

    public func executePhase(withContext context: RulesType.ContextType) {
        fatalError("BuilderPhase must be subclassed")
    }
}

public class DrawPhase : BuilderPhase {
    public override func executePhase(withContext context: RulesType.ContextType) {
        print("\(context.activePlayer.id) should draw some cards")
    }
}

public class DealPhase : BuilderPhase {
    public override func executePhase(withContext context: RulesType.ContextType) {
        print("\(context.activePlayer.id) should deal some cards")
    }
}
