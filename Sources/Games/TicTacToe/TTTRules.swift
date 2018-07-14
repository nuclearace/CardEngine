//
// Created by Erik Little on 7/14/18.
//

import Foundation
import Kit

public struct TTTRules : GameRules {
    public unowned let context: TTTGrid

    init(grid: TTTGrid) {
        self.context = grid
    }

    public func executeTurn() -> String {
        fatalError("executeTurn() has not been implemented")
    }

    public func getWinners() -> [TTTPlayer] {
        fatalError("getWinners() has not been implemented")
    }

    public func setupGame() {

    }
}
