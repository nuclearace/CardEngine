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
        let winners = rules.getWinners()

        guard winners.isEmpty else {
            // TODO(winners)
            return runLoop.newSucceededFuture(result: ())
        }

        return rules.executeTurn().then {[weak self] grid -> EventLoopFuture<()> in
            guard let this = self else { return deadGame() }

            this.grid = grid
            this.activeMark = !this.activeMark

            return this.runLoop.newSucceededFuture(result: ())
        }
    }

    public func startGame(withPlayers players: [TTTPlayer]) {

    }

    public func stopGame() {

    }
}
