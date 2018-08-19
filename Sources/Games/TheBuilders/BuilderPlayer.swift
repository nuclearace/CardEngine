//
// Created by Erik Little on 4/3/18.
//

import Foundation
import NIO
import Kit

public final class BuilderPlayer : InteractablePlayer {
    public typealias RulesType = BuildersRules
    public typealias InteractionType = BuildersInteraction
    public typealias InteractionReturnType = EventLoopFuture<BuildersPlayerResponse>

    /// The player's context.
    public unowned let context: BuildersBoard

    /// The unique identifier for this player.
    public let id = UUID()

    /// How the game interfaces with this player.
    public let interfacer: UserInterfacer

    public init(context: BuildersBoard, interfacer: UserInterfacer) {
        self.context = context
        self.interfacer = interfacer
    }

    #if DEBUG
    deinit {
        print("Player \(id) is dying")
    }
    #endif
}
