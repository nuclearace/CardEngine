//
// Created by Erik Little on 4/17/18.
//

import Foundation
import NIO

/// Represents a phase of a turn.
protocol BuilderPhase {
    /// The context that everything is working in.
    var context: BuildersBoard? { get }

    // FIXME passing context when context is stored is silly
    /// Executes this phase with context.
    func doPhase() -> EventLoopFuture<()>
}

private func newFuturePhase(to phase: BuilderPhase) -> EventLoopFuture<BuilderPhase> {
    guard let context = phase.context else {
        return currentEventLoop.newFailedFuture(error: BuildersError.gameDeath)
    }

    return context.runLoop.newSucceededFuture(result: phase)
}


func ~~> (lhs: BuilderPhase, rhs: BuilderPhase) -> EventLoopFuture<BuilderPhase> {
    return lhs.doPhase().then({_ in
        return newFuturePhase(to: rhs)
    })
}

func ~~> (lhs: EventLoopFuture<BuilderPhase>, rhs: BuilderPhase) -> EventLoopFuture<BuilderPhase> {
    return lhs.then {phase in
        return phase.doPhase().then({_ in
            return newFuturePhase(to: rhs)
        })
    }
}

/// A phase that goes through all cards in play and increments any counters.
///
/// The count phase is followed by the deal phase.
struct CountPhase : BuilderPhase {
    private(set) weak var context: BuildersBoard?

    func doPhase() -> EventLoopFuture<()> {
        guard let context = context else { return deadGame }

        // Go through all active accidents increment the turn
        for (player, accidents) in context.accidents {
            context.accidents[player] = accidents.map({accident in
                Accident(type: accident.type, turns: accident.turns + 1)
            })
        }

        return context.runLoop.newSucceededFuture(result: ())
    }
}

/// During the deal phase the player picks what playables they went to put into the game.
///
/// The deal phase is followed by the build phase.
struct DealPhase : BuilderPhase {
    private typealias HandReducer = (kept: BuildersHand, play: BuildersHand)

    private(set) weak var context: BuildersBoard?

    func doPhase() -> EventLoopFuture<()> {
        guard let context = context else { return deadGame }

        let active: BuilderPlayer = context.activePlayer

        var playedSomething = false
        var discardedSomething = false

        active.show("Your cards in play:\n", context.cardsInPlay[active, default: []].prettyPrinted())

        // These are strong captures, but if something happens, like a user disconnects, the promise will communicate
        // communicate a gameDeath error
        return getCardsToPlay(fromPlayer: active).then {[weak context] cards -> EventLoopFuture<()> in
            guard let context = context else { return deadGame }

            // Get the cards to play
            guard let played = self.playCards(cards, forPlayer: active, context: context) else {
                active.show("You played a card that you currently are unable to play\n")

                return context.runLoop.newFailedFuture(error: BuildersError.badPlay)
            }

            playedSomething = played.count > 0

            return context.runLoop.newSucceededFuture(result: ())
        }.then {_ -> EventLoopFuture<Set<Int>> in
            // Get cards to discard
            return self.getCardsToDiscard(fromPlayer: active)
        }.then {[weak context] cards -> EventLoopFuture<()> in
            guard let context = context else { return deadGame }

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
        context.accidents[context.players[1]] = played.accidents
        context.cardsInPlay[player, default: []].append(contentsOf: played.filter({ $0.playType != .accident }))

        return played
    }
}

/// During the build the phase, we calculate whether or nothing player built a new floor or not.
///
/// The build phase is followed by the draw phase.
struct BuildPhase : BuilderPhase {
    private(set) weak var context: BuildersBoard?

    func doPhase() -> EventLoopFuture<()> {
        guard let context = context else { return deadGame }

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
struct DrawPhase : BuilderPhase {
    private(set) weak var context: BuildersBoard?

    func doPhase() -> EventLoopFuture<()> {
        guard let context = context else { return deadGame }

        let active: BuilderPlayer = context.activePlayer

        print("\(context.activePlayer.id) should draw some cards")

        return getCards(needed: BuildersRules.cardsNeededInHand-active.hand.count, drawn: 0, context: context)
    }

    private func getCards(needed: Int, drawn: Int, context: BuildersBoard) -> EventLoopFuture<()> {
        guard drawn < needed else { return context.runLoop.newSucceededFuture(result: ()) }

        let active: BuilderPlayer = context.activePlayer

        return active.getInput(withDialog: "Draw:\n", "1: Worker\n2: Material\n3: Accident\n").then {input -> EventLoopFuture<()> in
            guard let choice = Int(input) else {
                return self.getCards(needed: needed, drawn: drawn, context: context)
            }

            switch choice {
            case 1:
                active.hand.append(Worker.getInstance())
            case 2:
                active.hand.append(Material.getInstance())
            case 3:
                active.hand.append(Accident.getInstance())
            default:
                return self.getCards(needed: needed, drawn: drawn, context: context)
            }

            return self.getCards(needed: needed, drawn: drawn + 1, context: context)
        }
    }
}

/// The last phase in a turn. This does any cleanup to put the context in a good state for the next player.
struct EndPhase : BuilderPhase {
    private(set) weak var context: BuildersBoard?

    func doPhase() -> EventLoopFuture<()> {
        guard let context = context else { return deadGame }

        // Filter out accidents that aren't valid anymore
        for (player, accidents) in context.accidents {
            context.accidents[player] = accidents.filter({accident in
                return accident.turns <= accident.type.turnsActive
            })
        }

        return context.runLoop.newSucceededFuture(result: ())
    }

    static func ~~> (lhs: EventLoopFuture<BuilderPhase>, rhs: EndPhase) -> EventLoopFuture<()> {
        return lhs.then {phase in
            return phase.doPhase().then({_ in rhs.doPhase() })
        }
    }
}
