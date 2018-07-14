//
// Created by Erik Little on 7/14/18.
//

import Foundation
import Kit
import NIO

public final class TTTPlayer : InteractablePlayer {
    public typealias RulesType = TTTRules

    public let id = UUID()
    public let interfacer: UserInterfacer

    public init(context: TTTGrid, interfacer: UserInterfacer) {
        self.interfacer = interfacer
    }

    public func send(_ dialog: UserInteraction<TTTInteraction>) {

    }

    public func getInput(_ object: UserInteraction<TTTInteraction>) -> EventLoopFuture<TTTInteractionResponse> {
        fatalError("getInput(object:) has not been implemented")
    }
}

