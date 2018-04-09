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
private var waitingForBuilders = [WebSocket]()

private let gameLocker = DispatchSemaphore(value: 1)

let ws = WebSocket.httpProtocolUpgrader(shouldUpgrade: {req in
    return [:]
}, onUpgrade: {websocket, req in
    print(websocket)

    websocket.onText {string in
        guard let maybeJson = try? JSONSerialization.jsonObject(with: string.data(using: .utf8)!),
              let json = maybeJson as? [String: Any] else {
            websocket.close()

            return
        }

        // TODO maybe use a third party json lib? Sounds kinda gross
        // TODO This is amazingly gross
        if let game = json["game"] as? String {
            defer { gameLocker.signal() }

            gameLocker.wait()

            // Make sure they aren't already waiting for a game
            guard !waitingForBuilders.contains(where: { websocket === $0 }) else { return }

            if waitingForBuilders.count >= 1 {
                print("Should start a game")
                waitingForBuilders.append(websocket)
                _ = group.next().scheduleTask(in: .milliseconds(1), startBuildersGame)
            } else {
                print("add to wait queue")
                waitingForBuilders.append(websocket)
            }
        }
    }
})

private func startBuildersGame() {
    defer { gameLocker.signal() }

    gameLocker.wait()

    guard waitingForBuilders.count >= 2 else {
        fatalError("Something went wrong, we should have two players waiting to start a game")
    }

    let board = BuildersBoard(runLoop: MultiThreadedEventLoopGroup.currentEventLoop!)
    let players = [
        BuilderPlayer(context: board, interfacer: WebSocketInterfacer(ws: waitingForBuilders[0], game:  board)),
        BuilderPlayer(context: board, interfacer: WebSocketInterfacer(ws: waitingForBuilders[1], game: board))
    ]

    board.setupPlayers(players)
    board.startGame()

    builderGames.append(board)
    waitingForBuilders = Array(waitingForBuilders.dropFirst(2))
}

// FIXME This is fugly
func gameStopped(game: AnyObject) {
    defer { gameLocker.signal() }

    gameLocker.wait()

    builderGames = builderGames.filter({ $0 !== game })
}
