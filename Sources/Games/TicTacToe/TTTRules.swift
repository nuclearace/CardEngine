//
// Created by Erik Little on 7/14/18.
//

import Foundation
import Kit
import NIO

public struct TTTRules : GameRules {
    public unowned let context: TTTGrid

    init(grid: TTTGrid) {
        self.context = grid
    }

    public func executeTurn() -> EventLoopFuture<TTTResult> {
        return context.activePlayer.getInput(
            UserInteraction(type: .turnStart, interaction: TTTInteraction())
        ).thenThrowing {[grid = context.grid, mark = context.activeMark] res in
            guard case let .play(x, y) = res else { throw GameError.badInput }
            guard x < 3 && x >= 0 else { throw GameError.badPlay }
            guard y < 3 && y >= 0 else { throw GameError.badPlay }
            guard grid[x][y] == nil else { throw GameError.badPlay }

            var grid = grid

            grid[x][y] = mark

            var (row, col, diag, antiDiag) = (0, 0, 0, 0)

            for i in 0..<3 {
                if grid[x][i] == mark { row += 1 }
                if grid[i][y] == mark { col += 1 }
                if grid[i][i] == mark { diag += 1 }
                if grid[i][3-i+1] == mark { antiDiag += 1 }
            }

            let winner = row == 3 || col == 3 || diag == 3 || antiDiag == 3

            return TTTResult(grid: grid, winner: winner ? mark : nil)
        }
    }

    public func getWinners() -> [TTTPlayer] {
        fatalError("Winners returned through executeTurn")
    }

    public func setupGame() {

    }
}

public struct TTTResult {
    public var grid: [[TTTMark?]]
    public var winner: TTTMark?
}
