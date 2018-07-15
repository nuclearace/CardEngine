//
// Created by Erik Little on 7/14/18.
//

import Foundation
import NIO
import Kit

public final class TTTGrid : GameContext {
    public static let name = "TicTacToe"

    public let id = UUID()

    public var activePlayer: TTTPlayer {
        return players[activeMark.index]
    }

    public private(set) var players = [TTTPlayer]()
    public private(set) var rules: TTTRules!

    private(set) var activeMark = TTTMark.X
    private(set) var grid = [[TTTMark?]](repeating: [TTTMark?](repeating: nil, count: 3), count: 3)

    private let runLoop: EventLoop

    public required init(runLoop: EventLoop) {
        self.runLoop = runLoop
        self.rules = TTTRules(grid: self)
    }

    @discardableResult
    private func nextTurn() -> EventLoopFuture<()> {
        return rules.executeTurn().then {[weak self] result -> EventLoopFuture<()> in
            guard let this = self else { return deadGame() }

            this.grid = result.grid
            this.activeMark = !this.activeMark

            if let winner = result.winner {
                // TODO(winner)
                return this.runLoop.newSucceededFuture(result: ())
            } else {
                return this.nextTurn()
            }
        }
    }

    public func startGame(withPlayers players: [TTTPlayer]) {

    }

    public func stopGame() {

    }
}
