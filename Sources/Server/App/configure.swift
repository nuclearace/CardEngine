//
// Created by Erik Little on 6/9/18.
//

import Foundation
import HTTP
import Service
import Vapor
import WebSocket

import TheBuilders

/// Called before your application initializes.
func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // try services.register(FluentSQLiteProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router, env)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig()

    // Serve static files in debug builds
    if !env.isRelease {
        middlewares.use(FileMiddleware.self)
    }

    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)

    // Setup WS
    let wss = NIOWebSocketServer.default()
    wss.get("join", use: handleUpgrade)
    services.register(wss, as: WebSocketServer.self)
}

private func handleUpgrade(_ websocket: WebSocket, _ request: Request) {
    websocket.onText {websocket, string in
        guard let maybeJson = try? JSONSerialization.jsonObject(with: string.data(using: .utf8)!),
              let json = maybeJson as? [String: Any] else {
            websocket.send("bad payload")
            websocket.close()

            return
        }

        guard let game = json["game"] as? String else {
            websocket.close()

            return
        }

        switch game {
        case BuildersBoard.name:
            Lobbies.buildersLobby.addPlayerToWait(websocket)
        case _:
            websocket.send("bad payload")
            websocket.close()
            return
        }
    }
}
