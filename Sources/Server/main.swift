import Async
import HTTP
import NIO
import Vapor
import Foundation
import WebSocket

struct HelloResponder : HTTPServerResponder {
    func respond(to request: HTTPRequest, on worker: Worker) -> EventLoopFuture<HTTPResponse> {
        let res = HTTPResponse(status: .ok, body: HTTPBody(string: "Hello, world!"))

        return Future.map(on: worker) { res }
    }
}

let server: HTTPServer
let group = MultiThreadedEventLoopGroup(numThreads: System.coreCount)

defer { try! group.syncShutdownGracefully() }

do {
    print("Starting server with \(System.coreCount) threads")

    let futureServer = HTTPServer.start(
            hostname: Environment.get("HOST") ?? "127.0.0.1",
            port: 8080,
            responder: HelloResponder(),
            upgraders: [ws],
            on: group
    ) {error in
        fatalError("Error starting server \(error)")
    }

    print("Waiting for server")

    server = try futureServer.wait()

    print("Server started")

    try server.onClose.wait()
} catch {
    print(error)
    exit(1)
}
