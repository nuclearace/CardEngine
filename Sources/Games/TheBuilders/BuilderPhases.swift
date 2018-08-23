//
// Created by Erik Little on 4/17/18.
//

import Foundation
import Kit
import NIO

/// Represents a phase of a turn.
protocol BuilderPhase {
    /// The context that everything is working in.
    var startingState: BuildersBoardState { get }

    /// Whether or not this phase should send syncing to players.
    var shouldSync: Bool { get }

    /// Creating a new phase.
    init(startingState: BuildersBoardState)

    /// Executes this phase with context.
    func doPhase() -> EventLoopFuture<BuildersBoardState>
}

extension BuilderPhase {
    func syncState() {
        guard shouldSync, let context = startingState.context else { return }

        let hands = startingState.cardsInPlay.byPlayerId(mappingValues: EncodableHand.init(hand:))
        let floors = startingState.hotels.byPlayerId(mappingValues: { $0.floorsBuilt })
        let interaction = BuildersInteraction(gameState: BuildersState(cardsInPlay: hands, floorsBuilt: floors))

        for player in context.players {
            player.send(UserInteraction(type: .gameState, interaction: interaction))
        }
    }
}

/// The names of player facing phases of a turn. These do not have to match the number of internal `BuilderPhase`s.
public enum BuildersPlayerPhaseName : String, Encodable {
    /// The player is going to place some cards on the board.
    case play

    /// The player is going to throw away some cards.
    case discard

    /// The player is going to draw some new cards.
    case draw

    /// This turn has progressed into the absolute phase of the game, the end.
    case gameOver
}

/// The start of a turn.
struct StartPhase : BuilderPhase {
    let shouldSync = false
    let startingState: BuildersBoardState

    func doPhase() -> EventLoopFuture<BuildersBoardState> {
        guard let context = startingState.context else { return deadGame() }

        context.activePlayer.send(UserInteraction(type: .turnStart, interaction: BuildersInteraction()))

        return context.runLoop.newSucceededFuture(result: startingState)
    }
}

/// A phase that goes through all cards in play and removes any accidents that have expired.
///
/// The count phase is followed by the deal phase.
struct CountPhase : BuilderPhase {
    let shouldSync = false
    let startingState: BuildersBoardState

    func doPhase() -> EventLoopFuture<BuildersBoardState> {
        guard let context = startingState.context else { return deadGame() }

        let active = context.activePlayer
        var state = startingState

        // Filter out accidents that aren't valid anymore
        state.accidents[active] = state.accidents[active, default: []].filter({accident in
            return accident.turns < accident.type.turnsActive
        })

        return context.runLoop.newSucceededFuture(result: state)
    }
}

/// During the deal phase the player picks what playables they went to put into the game.
///
/// The deal phase is followed by the build phase.
struct DealPhase : BuilderPhase {
    let shouldSync = true
    let startingState: BuildersBoardState

    func doPhase() -> EventLoopFuture<BuildersBoardState> {
        return getCardsToPlay().then(handlePlayed).then(getCardsToDiscard).then(finishUp)
    }

    private func getCardsToPlay() -> EventLoopFuture<BuildersHand> {
        guard let active = startingState.context?.activePlayer else {
            return deadGame()
        }

        let hand = startingState.cardsInHand[active, default: []]
        let input = active.getInput(
                UserInteraction(type: .turn,
                                interaction: BuildersInteraction(phase: .play, hand: hand)
                )
        )

        return input.map({response in
            guard case let .play(played) = response else {
                return []
            }

            return DealPhase.filterInvalidCards(hand: hand, toPlay: Set(played))
        })
    }

    private func handlePlayed(_ cards: BuildersHand) -> EventLoopFuture<DealPhaseResult> {
        guard let context = startingState.context else { return deadGame() }

        let active = context.activePlayer

        // Get the cards to play
        guard let result = playCards(cards, forPlayer: active) else {
            active.send(
                    UserInteraction(type: .playError,
                            interaction: BuildersInteraction(dialog: ["You played a card that you " +
                                    "currently are unable to play"])
                    )
            )

            return context.runLoop.newFailedFuture(error: GameError.badPlay)
        }

        return context.runLoop.newSucceededFuture(result: result)
    }

    private func playCards(_ cards: BuildersHand, forPlayer player: BuilderPlayer) -> DealPhaseResult? {
        // State hasn't changed yet, safe to read from startingState.
        guard let context = startingState.context else { return nil }

        var state = startingState

        let hand = state.cardsInHand[player, default: []]
        let (kept, played) = hand.reduce(into: ([], []), {(reducer: inout HandReducer, playable) in
            switch cards.contains(where: { $0 == playable }) {
            case true:
                reducer.play.append(playable)
            case false:
                reducer.kept.append(playable)
            }
        })

        // Check that all cards played are allowed
        for playedCard in played where !playedCard.canPlay(givenState: state, byPlayer: player) {
            return nil
        }

        state.cardsInHand[player] = kept
        state.accidents[context.players[1]] = played.accidents
        state.cardsInPlay[player, default: []].append(contentsOf: played.filter({ $0.playType != .accident }))

        return DealPhaseResult(played: played, discarded: [], state: state)
    }

    private func getCardsToDiscard(workingState: DealPhaseResult) -> EventLoopFuture<DealPhaseResult> {
        guard let active = startingState.context?.activePlayer else {
            return deadGame()
        }

        let hand = workingState.state.cardsInHand[active, default: []]
        let input = active.getInput(
                UserInteraction(type: .turn,
                                interaction: BuildersInteraction(phase: .discard, hand: hand)
                )
        )

        return input.map({[state = workingState.state] response in
            guard case let .discard(discarded) = response else {
                return DealPhaseResult(played: [], discarded: [], state: state)
            }

            return DealPhaseResult(played: workingState.played,
                                   discarded: DealPhase.filterInvalidCards(hand: hand, toPlay: Set(discarded)),
                                   state: workingState.state)
        })
    }

    private func finishUp(results: DealPhaseResult) -> EventLoopFuture<BuildersBoardState> {
        guard let context = startingState.context else { return deadGame() }

        let active = context.activePlayer

        // TODO Should they have to play something?
        guard !results.played.isEmpty || !results.discarded.isEmpty else {
            active.send(
                    UserInteraction(type: .playError,
                            interaction: BuildersInteraction(dialog: ["You must do something!"])
                    )
            )

            return context.runLoop.newFailedFuture(error: GameError.badPlay)
        }

        var state = results.state

        let hand = state.cardsInHand[active, default: []]

        // Discard those cards
        state.cardsInHand[active] = BuildersHand(playables: hand.lazy.filter({cardInHand in
            return !results.discarded.contains(where: { $0 == cardInHand })
        }), maxPlayables: BuildersRules.cardsNeededInHand)

        return context.runLoop.newSucceededFuture(result: state)
    }

    private static func filterInvalidCards(hand: BuildersHand, toPlay: Set<String>) -> BuildersHand {
        return BuildersHand(playables: hand.filter({ toPlay.contains($0.id.uuidString) }))
    }

    private typealias HandReducer = (kept: BuildersHand, play: BuildersHand)

    private struct DealPhaseResult {
        var played = BuildersHand()
        var discarded = BuildersHand()
        var state: BuildersBoardState
    }
}

/// During the build the phase, we calculate whether or not player built a new floor or not.
///
/// The build phase is followed by the draw phase.
struct BuildPhase : BuilderPhase {
    let shouldSync = false
    let startingState: BuildersBoardState

    func doPhase() -> EventLoopFuture<BuildersBoardState> {
        guard let context = startingState.context else { return deadGame() }

        let active: BuilderPlayer = context.activePlayer
        var state = startingState

        guard var hand = state.cardsInPlay[active] else {
            return context.runLoop.newSucceededFuture(result: state)
        }

        state.hotels[active]?.calculateNewFloors(fromPlayedCards: &hand)
        state.cardsInPlay[active] = hand

        return context.runLoop.newSucceededFuture(result: state)
    }
}

/// During the draw phase, the player's hand is restocked with playables.
///
/// The draw phase concludes a turn.
struct DrawPhase : BuilderPhase {
    let shouldSync = true
    let startingState: BuildersBoardState

    func doPhase() -> EventLoopFuture<BuildersBoardState> {
        guard let context = startingState.context else { return deadGame() }

        let active: BuilderPlayer = context.activePlayer
        let hand = startingState.cardsInHand[active, default: []]

        #if DEBUG
        print("\(context.activePlayer.id) should draw some cards")
        #endif

        return getCards(needed: BuildersRules.cardsNeededInHand-hand.count, drawn: 0, state: startingState)
    }

    private func getCards(needed: Int, drawn: Int, state: BuildersBoardState) -> EventLoopFuture<BuildersBoardState> {
        guard let context = state.context else { return deadGame() }
        guard drawn < needed else { return context.runLoop.newSucceededFuture(result: state) }

        let active: BuilderPlayer = context.activePlayer
        let interaction = UserInteraction(type: .turn, interaction: BuildersInteraction(phase: .draw))

        func handleDraw(response: BuildersPlayerResponse) -> EventLoopFuture<BuildersBoardState> {
            guard let context = state.context else { return deadGame() }
            guard case let .draw(drawType) = response else {
                return self.getCards(needed: needed, drawn: drawn, state: state)
            }

            let active: BuilderPlayer = context.activePlayer
            var state = state

            switch drawType {
            case .worker:
                state.cardsInHand[active]?.append(Worker.getInstance())
            case .material:
                state.cardsInHand[active]?.append(Material.getInstance())
            case .accident:
                state.cardsInHand[active]?.append(Accident.getInstance())
            }

            return self.getCards(needed: needed, drawn: drawn + 1, state: state)
        }

        return active.getInput(interaction).then(handleDraw).thenIfError {_ in
            return self.getCards(needed: needed, drawn: drawn, state: state)
        }
    }
}

/// The last phase in a turn. This does any cleanup to put the context in a good state for the next player.
struct EndPhase : BuilderPhase {
    let shouldSync = false
    let startingState: BuildersBoardState

    func doPhase() -> EventLoopFuture<BuildersBoardState> {
        guard let context = startingState.context else { return deadGame() }

        let active = context.activePlayer
        var state = startingState

        active.send(UserInteraction(type: .turnEnd, interaction: BuildersInteraction()))

        // Go through all active accidents increment the turn
        state.accidents[active] = state.accidents[active, default: []].map({accident in
            return Accident(type: accident.type, turns: accident.turns + 1)
        })

        return context.runLoop.newSucceededFuture(result: state)
    }

    static func ~~> (lhs: EventLoopFuture<BuilderPhase>, rhs: EndPhase.Type) -> EventLoopFuture<BuildersBoardState> {
        return lhs.then {phase in
            phase.syncState()

            return phase.doPhase().then({state in rhs.init(startingState: state).doPhase() })
        }
    }
}

private func newFuturePhase(
    _ phase: BuilderPhase.Type,
    withStateChanger changer: BuildersBoardState
) -> EventLoopFuture<BuilderPhase> {
    guard let context = changer.context else {
        return currentEventLoop.newFailedFuture(error: GameError.gameDeath)
    }

    return context.runLoop.newSucceededFuture(result: phase.init(startingState: changer))
}

func ~~> (lhs: BuildersBoardState, rhs: BuilderPhase.Type) -> BuilderPhase {
    return rhs.init(startingState: lhs)
}

func ~~> (lhs: BuilderPhase, rhs: BuilderPhase.Type) -> EventLoopFuture<BuilderPhase> {
    lhs.syncState()

    return lhs.doPhase().then({state in
        return newFuturePhase(rhs, withStateChanger: state)
    })
}

func ~~> (lhs: EventLoopFuture<BuilderPhase>, rhs: BuilderPhase.Type) -> EventLoopFuture<BuilderPhase> {
    return lhs.then({phase in
        phase.syncState()

        return phase.doPhase().then({changer in
            return newFuturePhase(rhs, withStateChanger: changer)
        })
    })
}
