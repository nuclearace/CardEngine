//
// Created by Erik Little on 4/3/18.
//

import Foundation
import Kit

/// The game of The Builders.
public struct BuildersRules : GameRules {
    fileprivate static let cardsNeededInHand = 7

    /// The context these rules are applying to
    public unowned let context: BuildersBoard

    /// What a turn looks like in this game. A turn consists of a set of phases that are executed in order.
    public let turn = [DealPhase(), BuildPhase(), DrawPhase()]

    private var moveCount = 0

    public init(context: BuildersBoard) {
        self.context = context
    }

    /// Executes player's turn.
    ///
    /// - parameter forPLayer: The player whose turn it is.
    public mutating func executeTurn(forPlayer player: BuilderPlayer) {
        print("\(player.id)'s turn")

        for phase in turn {
            phase.executePhase(withContext: context)
        }

        moveCount += 1
    }

    /// Calculates whether or not this game is over, based on some criteria.
    ///
    /// - returns: `true` if this game is over, false otherwise.
    public func isGameOver() -> Bool {
        return context.hotels.map({ $0.value.floorsBuilt }).reduce(0, +) > 0
    }

    /// Starts a game. This is called to deal cards, give money, etc, before the first player goes.
    public mutating func setupGame() {
        for player in context.players {
            player.hand = Array(0..<BuildersRules.cardsNeededInHand).map({_ -> BuildersPlayable in Worker.getInstance() })
        }
    }
}

public class BuilderPhase : Phase {
    public typealias RulesType = BuildersRules

    public func executePhase(withContext context: RulesType.ContextType) {
        fatalError("BuilderPhase must be subclassed")
    }
}

// TODO Allow discard
/// During the deal phase the player picks what playables they went to put into the game.
///
/// The deal phase is followed by the build phase.
public final class DealPhase : BuilderPhase {
    private typealias HandReducer = (kept: BuilderHand, play: BuilderHand)

    public override func executePhase(withContext context: BuildersBoard) {
        let active: BuilderPlayer = context.activePlayer
        let cardsToPlay = getCardsToPlay(fromPlayer: active)
        let played = playCards(cardsToPlay, forPlayer: active, context: context)
        let cardsToDiscard = getCardsToDiscard(fromPlayer: active)

        active.hand = active.hand.enumerated().filter({ !cardsToDiscard.contains($0.offset + 1) }).map({ $0.element })

        // TODO Should they have to play something?
        // FIXME this should probably have a depth counter to avoid someone causing max recursion
        guard cardsToPlay.count > 0 || cardsToDiscard.count > 0 else {
            print("You must do something!")

            return executePhase(withContext: context)
        }

        print("\(active.id) will play \(played)")
    }

    private func playCards(_ cards: Set<Int>, forPlayer player: BuilderPlayer, context: BuildersBoard) -> BuilderHand {
        // Split into kept and played
        let enumeratedHand = player.hand.enumerated()
        let (kept, played) = enumeratedHand.reduce(into: ([], []), {(reducer: inout HandReducer, playable) in
            switch cards.contains(playable.offset + 1) {
            case true:
                reducer.play.append(playable.element)
            case false:
                reducer.kept.append(playable.element)
            }
        })

        player.hand = kept
        context.cardsInPlay[player, default: []].append(contentsOf: played)

        return played
    }

    private func getCardsToPlay(fromPlayer player: BuilderPlayer) -> Set<Int> {
        let input = player.getInput(withDialog: "Your hand: \(player.hand)\n", "Which cards would you like to play? ")

        return parseInputCards(input: input, player: player)
    }

    private func getCardsToDiscard(fromPlayer player: BuilderPlayer) -> Set<Int> {
        let input = player.getInput(withDialog: "Your hand \(player.hand)\n", "Would you like discard something?")

        return parseInputCards(input: input, player: player)
    }

    private func parseInputCards(input: String, player: BuilderPlayer) -> Set<Int> {
        return Set(input.components(separatedBy: ",")
                        .map({ $0.replacingOccurrences(of: " ", with: "") })
                        .map(Int.init)
                        .compactMap({ $0 })
                        .filter({ $0 > 0 && $0 <= player.hand.count }))
    }
}

/// During the build the phase, we calculate whether or nothing player built a new floor or not.
///
/// The build phase is followed by the draw phase.
public final class BuildPhase : BuilderPhase {
    public override func executePhase(withContext context: BuildersBoard) {
        let active: BuilderPlayer = context.activePlayer
        var hotel = context.hotels[active, default: Hotel()]

        guard var hand = context.cardsInPlay[active] else {
            return
        }

        defer {
            context.cardsInPlay[active] = hand
            context.hotels[active] = hotel
        }

        hotel.calculateNewFloors(fromPlayedCards: &hand)
    }
}

/// During the draw phase, the player's hand is restocked with playables.
///
/// The draw phase concludes a turn.
public final class DrawPhase : BuilderPhase {
    public override func executePhase(withContext context: BuildersBoard) {
        let active: BuilderPlayer = context.activePlayer

        print("\(context.activePlayer.id) should draw some cards")

        for _ in 0..<BuildersRules.cardsNeededInHand-active.hand.count {
            active.hand.append(Worker.getInstance())
        }
    }
}
