import Service
import Vapor
import Foundation
import WebSocket

struct HelloResponder: HTTPResponder {
    func respond(to request: HTTPRequest, on worker: Worker) -> EventLoopFuture<HTTPResponse> {
        let res = HTTPResponse(status: .ok, body: HTTPBody(string: "Hello, world!"))

        return Future.map(on: worker) { res }
    }
}

// The contents of main are wrapped in a do/catch block because any errors that get raised to the top level will crash Xcode
do {
    let group = MultiThreadedEventLoopGroup(numThreads: Int(Environment.get("NUM_THREADS") ?? "1") ?? 1)

    let server = try HTTPServer.start(
            hostname: Environment.get("HOST") ?? "127.0.0.1",
            port: 8080,
            responder: HelloResponder(),
            upgraders: [ws],
            on: group
    ) {error in
        return
    }.wait()

    try server.onClose.wait()
} catch {
    print(error)
    exit(1)
}
