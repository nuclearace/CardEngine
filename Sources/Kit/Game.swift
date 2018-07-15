//
// Created by Erik Little on 4/2/18.
//

import Foundation
import NIO

/// Represents the state of a game.
public protocol GameContext : AnyObject {
    // MARK: Typealiases

    /// The type of game this context is playing.
    associatedtype RulesType: GameRules where RulesType.ContextType == Self

    // MARK: Properties

    /// The name of this game.
    static var name: String { get }

    /// The player who is currently making moves
    var activePlayer: RulesType.PlayerType { get }

    /// The id for this game.
    var id: UUID { get }

    /// The players in this game.
    var players: [RulesType.PlayerType] { get }

    /// The rules for the game executing in this context.
    var rules: RulesType! { get }

    // MARK: Initializers

    /// Creates a new game controlled on `runLoop`.
    init(runLoop: EventLoop)

    // MARK: Methods

    /// Starts this game with the given players.
    ///
    /// - parameter withPlayers: The `Player`s for this game.
    func startGame(withPlayers players: [RulesType.PlayerType])

    /// Halts this game.
    func stopGame()
}

/// Gets the current event loop. Only valid when called from inside an event loop.
public var currentEventLoop: EventLoop {
    return MultiThreadedEventLoopGroup.currentEventLoop!
}

/// Returns a new failed future for the current event loop. Return when a game has died.
public func deadGame<T>() -> EventLoopFuture<T> {
    return currentEventLoop.newFailedFuture(error: GameError.gameDeath)
}

/// Generic game errors.
public enum GameError : Error {
    /// The game can be considered dead, and its memory ready for releasing.
    case gameDeath

    /// The game received bad input from a player.
    case badInput

    /// A player made an illegal move.
    case badPlay
}
