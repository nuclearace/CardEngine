//
// Created by Erik Little on 7/14/18.
//

import Foundation
import Kit
import NIO

public struct TTTRules : GameRules {
    public unowned let context: TTTGrid

    var winner: TTTMark? = nil

    init(grid: TTTGrid) {
        self.context = grid
    }

    public func executeTurn() -> EventLoopFuture<[[TTTMark?]]> {
        return context.activePlayer.getInput(
            UserInteraction(type: .turnStart, interaction: TTTInteraction())
        ).thenThrowing {[grid = context.grid, mark = context.activeMark] res in
            guard case let .play(x, y) = res else { throw GameError.badInput }
            guard x < 3 && x >= 0 else { throw GameError.badPlay }
            guard y < 3 && y >= 0 else { throw GameError.badPlay }
            guard grid[x][y] == nil else { throw GameError.badPlay }

            var grid = grid

            grid[x][y] = mark

            // TODO(winner)

            return grid
        }
    }

    public func getWinners() -> [TTTPlayer] {
        guard let winner = self.winner else { return [] }

        return [context.players[winner.index]]
    }

    public func setupGame() {

    }
}
