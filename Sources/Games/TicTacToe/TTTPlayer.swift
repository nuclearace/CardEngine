//
// Created by Erik Little on 7/14/18.
//

import Foundation
import Kit
import NIO

public final class TTTPlayer : InteractablePlayer {
    public typealias RulesType = TTTRules
    public typealias InteractionType = TTTInteraction
    public typealias InteractionReturnType = EventLoopFuture<TTTInteractionResponse>

    public unowned let context: TTTGrid
    public let id = UUID()
    public let interfacer: UserInterfacer

    public init(context: TTTGrid, interfacer: UserInterfacer) {
        self.context = context
        self.interfacer = interfacer
    }
}

