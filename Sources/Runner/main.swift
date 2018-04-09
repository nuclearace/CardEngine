import CoreFoundation
import Foundation
import Kit
import NIO
import Games

let group = MultiThreadedEventLoopGroup(numThreads: 1)
let loop = group.next()
let theBuilders = BuildersBoard(runLoop: loop)

theBuilders.setupPlayers([BuilderPlayer(context: theBuilders, interfacer: ConsoleInterfacer()),
                          BuilderPlayer(context: theBuilders, interfacer: ConsoleInterfacer())])
theBuilders.startGame()

// FIXME is there a way in NIO to start the runloop?
CFRunLoopRun()
