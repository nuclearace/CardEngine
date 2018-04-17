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
