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

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

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

    #if DEBUG
    deinit {
        print("Player \(id) is dying")
    }
    #endif

    /// Prints some dialog to the player.
    public func send(_ dialog: UserInteraction<BuildersInteraction>) {
        guard let encoded = try? encoder.encode(dialog) else {
            fatalError("Error creating JSON for builders")
        }

        interfacer.send(String(data: encoded, encoding: .utf8)!)
    }

    /// Gets some input from the user.
    ///
    /// - parameter object: The object to send to the user.
    /// - returns: The input from the user.
    public func getInput(_ dialog: UserInteraction<BuildersInteraction>) -> EventLoopFuture<BuildersPlayerResponse> {
        guard let encoded = try? encoder.encode(dialog) else {
            fatalError("Error creating JSON for builders")
        }

        let p: EventLoopPromise<String> = context.runLoop.newPromise()

        interfacer.getInput(withDialog: String(data: encoded, encoding: .utf8)!, withPromise: p)

        return p.futureResult.thenThrowing({[decoder = self.decoder] str in
            return try decoder.decode(BuildersPlayerResponse.self, from: str.data(using: .utf8)!)
        })
    }
}
