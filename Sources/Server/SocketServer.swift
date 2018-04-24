//
// Created by Erik Little on 4/8/18.
//

import Foundation
import Dispatch
import Games
import NIO
import Kit
import Vapor
import WebSocket

// TODO lobby

// FIXME this is fugly
private var builderGames = [AnyObject]()
private var waitingForBuilders = [(ws: WebSocket, loop: EventLoop)]()

private let gameLocker = DispatchSemaphore(value: 1)

let ws = WebSocket.httpProtocolUpgrader(shouldUpgrade: {req in
    return [:]
}, onUpgrade: {websocket, req in
    websocket.onText {string in
        guard let maybeJson = try? JSONSerialization.jsonObject(with: string.data(using: .utf8)!),
              let json = maybeJson as? [String: Any] else {
            websocket.close()

            return
        }

        guard let game = json["game"] as? String else { return }

        defer { gameLocker.signal() }

        gameLocker.wait()

        // Make sure they aren't already waiting for a game
        guard !waitingForBuilders.contains(where: { websocket === $0.0 }) else { return }

        if waitingForBuilders.count >= 1 {
            print("Should start a game")
            waitingForBuilders.append((websocket, MultiThreadedEventLoopGroup.currentEventLoop!))
            startBuildersGame(loop: group.next())
        } else {
            print("add to wait queue")
            waitingForBuilders.append((websocket, MultiThreadedEventLoopGroup.currentEventLoop!))
        }
    }

    websocket.onClose {
        defer { gameLocker.signal() }

        gameLocker.wait()

        waitingForBuilders = waitingForBuilders.filter({ $0.0 !== websocket })
    }
})

private func startBuildersGame(loop: EventLoop) {
    guard waitingForBuilders.count >= 2 else {
        fatalError("Something went wrong, we should have two players waiting to start a game")
    }

    let board = BuildersBoard(runLoop: loop)
    let players = [
        BuilderPlayer(context: board,
                      interfacer: WebSocketInterfacer(ws: waitingForBuilders[0].ws,
                                                      game:  board,
                                                      onLoop: waitingForBuilders[0].loop)),
        BuilderPlayer(context: board,
                      interfacer: WebSocketInterfacer(ws: waitingForBuilders[1].ws,
                                                      game: board,
                                                      onLoop: waitingForBuilders[1].loop))
    ]

    board.setupPlayers(players)
    board.startGame()

    builderGames.append(board)
    waitingForBuilders = Array(waitingForBuilders.dropFirst(2))
}

// FIXME This is fugly
func gameStopped(_ game: AnyObject) {
    defer { gameLocker.signal() }

    gameLocker.wait()

    builderGames = builderGames.filter({ $0 !== game })
}
