//
// Created by Erik Little on 4/3/18.
//

import Foundation
import Kit

/// The game of The Builders.
public struct TheBuildersRules : GameRules {
    public typealias ContextType = BuildersBoard
//    public typealias PhaseType = TheBuilderPhase

    /// What a turn looks like in this game. A turn consists of a set of phases that are executed in order.
    public let turn = [DrawPhase(), DealPhase()]

    /// The context these rules are applying to
    public unowned var context: BuildersBoard

    private var moveCount = 0

    public init(context: BuildersBoard) {
        self.context = context
    }

    /// Executes player's turn.
    ///
    /// - parameter forPLayer: The player whose turn it is.
    public mutating func executeTurn(forPlayer player: TheBuilderPlayer) {
        print("It's \(player.id)'s turn")
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

public final class TheBuilderPlayer : Player {
    public let id = UUID()

    public init () {}
}

public class TheBuilderPhase : Phase {
    public typealias RulesType = TheBuildersRules

    public func executePhase(withContext context: RulesType.ContextType) {
        fatalError("TheBuilderPhase must be subclassed")
    }
}

public class DrawPhase : TheBuilderPhase {
    public typealias RulesType = TheBuildersRules

    public override func executePhase(withContext context: RulesType.ContextType) {

    }
}

public class DealPhase : TheBuilderPhase {
    public typealias RulesType = TheBuildersRules

    public override func executePhase(withContext context: RulesType.ContextType) {

    }
}
