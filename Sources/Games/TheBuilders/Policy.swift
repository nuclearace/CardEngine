//
// Created by Erik Little on 4/9/18.
//

import Foundation
import NIO

// Internal helpers for Builders

infix operator ~~> : PhasePrecedenceGroup

precedencegroup PhasePrecedenceGroup {
    associativity: left
}

/// Gets the current event loop. Only valid when called from inside an event loop.
var currentEventLoop: EventLoop {
    return MultiThreadedEventLoopGroup.currentEventLoop!
}

/// Returns a new failed future for the current event loop. Return when a game has died.
var deadGame: EventLoopFuture<()> {
    return currentEventLoop.newFailedFuture(error: BuildersError.gameDeath)
}

// MARK: Errors

/// Errors that can occur during a game
enum BuildersError : Error {
    /// A bad hand was played
    case badPlay

    /// The game has gone and died.
    case gameDeath
}

// TODO find a better place for this.
func parseGameMove(fromInput input: String) -> [String: Any]? {
    guard let json = try? JSONSerialization.jsonObject(with: input.data(using: .utf8)!) as? [String: Any] else {
        return nil
    }

    return json
}

