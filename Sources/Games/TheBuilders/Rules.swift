//
// Created by Erik Little on 4/3/18.
//

import Foundation
import Kit

/// The game of The Builders.
public struct BuildersRules : GameRules {
    /// The context these rules are applying to
    public unowned let context: BuildersBoard

    /// What a turn looks like in this game. A turn consists of a set of phases that are executed in order.
    public let turn = [DrawPhase(), DealPhase()]

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
        let active: BuilderPlayer = context.activePlayer

        print("\(context.activePlayer.id) should draw some cards")
        active.hand.append(Worker.getInstance())
    }
}

public class DealPhase : BuilderPhase {
    public override func executePhase(withContext context: RulesType.ContextType) {
        let active: BuilderPlayer = context.activePlayer
        let cardsToRemove = getCardsToPlay(fromPlayer: active)

        print("\(active.id) will play \(cardsToRemove)")

        active.hand = active.hand.enumerated().filter({i in
            return !cardsToRemove.contains(i.0 + 1)
        }).map({ $0.1 })
    }

    private func getCardsToPlay(fromPlayer player: BuilderPlayer) -> Set<Int> {
        let input = player.getInput(withDialog: "Your hand: \(player.hand)", "Which cards would you like to play? ")

        // If they put a single num
        if let int = Int(input) {
            return [int]
        }

        let cards = Set(input.components(separatedBy: ",")
                         .map({ $0.replacingOccurrences(of: " ", with: "") })
                         .map(Int.init).compactMap({ $0 }))

        // FIXME this should probably have a depth counter to avoid someone causing max recursion
        guard cards.count > 1 else {
            print("You must play something!")

            return getCardsToPlay(fromPlayer: player)
        }

        return cards
    }
}
