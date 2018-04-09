//
// Created by Erik Little on 4/3/18.
//

import Foundation
import NIO
import Kit

/// The game of The Builders.
public struct BuildersRules : GameRules {
    fileprivate static let cardsNeededInHand = 7

    /// The context these rules are applying to
    public unowned let context: BuildersBoard

    /// What a turn looks like in this game. A turn consists of a set of phases that are executed in order.
    public let turn: [BuilderPhase]

    private var moveCount = 0

    public init(context: BuildersBoard) {
        self.context = context
        self.turn = [DealPhase(context: context), DrawPhase(context: context), BuildPhase(context: context)]
    }

    /// Executes player's turn.
    ///
    /// - parameter forPLayer: The player whose turn it is.
    public mutating func executeTurn(forPlayer player: BuilderPlayer) -> EventLoopFuture<()> {
        print("\(player.id)'s turn")

        moveCount += 1

        // TODO Does it make sense to have a turn when we just do this?
        return turn[0] ~~> turn[1] ~~> turn[2] ~~> EndPhase(context: context)
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

public class BuilderPhase : Phase {
    public typealias RulesType = BuildersRules

    private unowned let context: BuildersBoard

    fileprivate init(context: BuildersBoard) {
        self.context = context
    }

    deinit {
        print("\(type(of: self)) is dying")
    }

    public func executePhase(withContext context: BuildersBoard) -> EventLoopFuture<()> {
        fatalError("BuilderPhase must be subclassed")
    }

    fileprivate func doPhase() -> EventLoopFuture<()> {
        return executePhase(withContext: context)
    }

    // TODO Maybe make this available on kit?
    fileprivate static func ~~> (lhs: BuilderPhase, rhs: BuilderPhase) -> EventLoopFuture<BuilderPhase> {
        return lhs.doPhase().then({_ in rhs.context.runLoop.newSucceededFuture(result: rhs) })
    }

    fileprivate static func ~~> (lhs: EventLoopFuture<BuilderPhase>, rhs: BuilderPhase) -> EventLoopFuture<BuilderPhase> {
        return lhs.then {phase in
            return phase.doPhase().then({_ in rhs.context.runLoop.newSucceededFuture(result: rhs) })
        }
    }
}

/// During the deal phase the player picks what playables they went to put into the game.
///
/// The deal phase is followed by the build phase.
public final class DealPhase : BuilderPhase {
    private typealias HandReducer = (kept: BuildersHand, play: BuildersHand)

    public override func executePhase(withContext context: BuildersBoard) -> EventLoopFuture<()> {
        let active: BuilderPlayer = context.activePlayer

        var playedSomething = false
        var discardedSomething = false

        active.show("Your cards in play:\n", context.cardsInPlay[active, default: []].prettyPrinted())

        // These are strong captures, but if something happens, like a user disconnects, the promise will communicate
        // communicate a gameDeath error
        return getCardsToPlay(fromPlayer: active).then {cards -> EventLoopFuture<()> in
            // Get the cards to play
            guard let played = self.playCards(cards, forPlayer: active, context: context) else {
                active.show("You played a card that you currently are unable to play\n")

                return context.runLoop.newFailedFuture(error: BuildersError.badPlay)
            }

            playedSomething = played.count > 0

            return context.runLoop.newSucceededFuture(result: ())
        }.then {future -> EventLoopFuture<Set<Int>> in
            // Get cards to discard
            return self.getCardsToDiscard(fromPlayer: active)
        }.then {cards -> EventLoopFuture<()> in
            // Discard those cards
            discardedSomething = cards.count > 0

            active.hand = active.hand.enumerated().filter({ !cards.contains($0.offset + 1) }).map({ $0.element })

            // TODO Should they have to play something?
            guard playedSomething || discardedSomething else {
                active.show("You must do something!\n")

                return context.runLoop.newFailedFuture(error: BuildersError.badPlay)
            }

            return context.runLoop.newSucceededFuture(result: ())
        }
    }

    private func getCardsToPlay(fromPlayer player: BuilderPlayer) -> EventLoopFuture<Set<Int>> {
        let input = player.getInput(withDialog: "Your hand: \n",
                                    player.hand.prettyPrinted(),
                                    "Which cards would you like to play? ")

        return input.map({inputString in
            return self.parseInputCards(input: inputString, player: player)
        })
    }

    private func getCardsToDiscard(fromPlayer player: BuilderPlayer) -> EventLoopFuture<Set<Int>> {
        let input = player.getInput(withDialog: "Your hand: \n",
                                    player.hand.prettyPrinted(),
                                    "Would you like discard something?")

        return input.map({inputString in
            return self.parseInputCards(input: inputString, player: player)
        })
    }

    private func parseInputCards(input: String, player: BuilderPlayer) -> Set<Int> {
        return Set(input.components(separatedBy: ",")
                        .map({ $0.replacingOccurrences(of: " ", with: "") })
                        .map(Int.init)
                        .compactMap({ $0 })
                        .filter({ $0 > 0 && $0 <= player.hand.count }))
    }

    private func playCards(_ cards: Set<Int>, forPlayer player: BuilderPlayer, context: BuildersBoard) -> BuildersHand? {
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

        // Check that all cards played are allowed
        for playedCard in played where !playedCard.canPlay(inContext: context, byPlayer: player) {
            return nil
        }

        player.hand = kept
        context.cardsInPlay[player, default: []].append(contentsOf: played)

        return played
    }
}

/// During the build the phase, we calculate whether or nothing player built a new floor or not.
///
/// The build phase is followed by the draw phase.
public final class BuildPhase : BuilderPhase {
    public override func executePhase(withContext context: BuildersBoard) -> EventLoopFuture<()> {
        let active: BuilderPlayer = context.activePlayer
        var hotel = context.hotels[active, default: Hotel()]

        guard var hand = context.cardsInPlay[active] else {
            return context.runLoop.newSucceededFuture(result: ())
        }

        defer {
            context.cardsInPlay[active] = hand
            context.hotels[active] = hotel
        }

        hotel.calculateNewFloors(fromPlayedCards: &hand)

        return context.runLoop.newSucceededFuture(result: ())
    }
}

/// During the draw phase, the player's hand is restocked with playables.
///
/// The draw phase concludes a turn.
public final class DrawPhase : BuilderPhase {
    public override func executePhase(withContext context: BuildersBoard) -> EventLoopFuture<()> {
        let active: BuilderPlayer = context.activePlayer

        print("\(context.activePlayer.id) should draw some cards")

        return getCards(needed: BuildersRules.cardsNeededInHand-active.hand.count, drawn: 0, context: context)
    }

    private func getCards(needed: Int, drawn: Int, context: BuildersBoard) -> EventLoopFuture<()> {
        guard drawn < needed else { return context.runLoop.newSucceededFuture(result: ()) }

        let active: BuilderPlayer = context.activePlayer

        return active.getInput(withDialog: "Draw:\n", "1: Worker\n2: Material\n").then {input -> EventLoopFuture<()> in
            guard let choice = Int(input) else {
                return self.getCards(needed: needed, drawn: drawn, context: context)
            }

            switch choice {
            case 1:
                active.hand.append(Worker.getInstance())
            case 2:
                active.hand.append(Material.getInstance())
            default:
                return self.getCards(needed: needed, drawn: drawn, context: context)
            }

            return self.getCards(needed: needed, drawn: drawn + 1, context: context)
        }
    }
}

public final class EndPhase : BuilderPhase {
    public override func executePhase(withContext context: BuildersBoard) -> EventLoopFuture<()> {
        return context.runLoop.newSucceededFuture(result: ())
    }

    fileprivate static func ~~> (lhs: EventLoopFuture<BuilderPhase>, rhs: EndPhase) -> EventLoopFuture<()> {
        return lhs.then {phase in
            return phase.doPhase().then({_ in rhs.doPhase() })
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
