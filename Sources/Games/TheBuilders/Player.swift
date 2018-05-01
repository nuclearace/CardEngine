//
// Created by Erik Little on 4/3/18.
//

import Foundation
import NIO
import Kit

public final class BuilderPlayer : InteractablePlayer {
    public typealias RulesType = BuildersRules

    /// The unique identifier for this player.
    public let id = UUID()

    /// How the game interfaces with this player.
    public let interfacer: UserInterfacer

    private unowned let context: BuildersBoard

    /// The playable items that this player has. This are items that are not in play.
    public internal(set) var hand = [BuildersPlayable]() {
        didSet {
            precondition(hand.count <= 7, "A player should not have more than 7 playables in their at any time")
        }
    }

    public init(context: BuildersBoard, interfacer: UserInterfacer) {
        self.context = context
        self.interfacer = interfacer
    }

    deinit {
        print("Player \(id) is dying")
    }

    /// Prints some dialog to the player.
    public func show(_ dialog: String...) {
        interfacer.send(dialog.joined())
    }

    /// Gets some input from the user.
    ///
    /// - parameter withDialog: The text to display to the user.
    /// - returns: The input from the user.
    public func getInput(withDialog dialog: String...) -> EventLoopFuture<String> {
        let p: EventLoopPromise<String> = context.runLoop.newPromise()

        interfacer.getInput(withDialog: dialog.joined(), withPromise: p)

        return p.futureResult
    }
}
