//
// Created by Erik Little on 4/8/18.
//

import Foundation
import WebSocket

let ws = WebSocket.httpProtocolUpgrader(shouldUpgrade: {req in
    return [:]
}, onUpgrade: {ws, req in
    ws.onText {string in
        print("Got \(string)")

        ws.send(string)
    }
})
