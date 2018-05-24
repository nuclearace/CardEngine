//
// Created by Erik Little on 4/3/18.
//

import Foundation
import NIO

/// Represents a user.
public protocol Player : AnyObject, Hashable {
    associatedtype RulesType: GameRules where RulesType.PlayerType == Self

    /// The unique identifier for this player.
    var id: UUID { get }
}

extension Player {
    public var hashValue: Int {
        return id.hashValue
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Says that a type will be able to interface with a user.
public protocol UserInterfacer {
    /// The promise to the game that some input will be returned.
    var responsePromise: EventLoopPromise<String>? { get }

    /// Sends a string to the user.
    func send(_ str: String)

    /// Gets some input from this user.
    func getInput(withDialog dialog: String, withPromise promise: EventLoopPromise<String>)
}

/// Protocol that declares the interface for interacting with users
public protocol InteractablePlayer : Player {
    /// The input type.
    associatedtype InteractionInputType = String

    /// The type returned from interactions.
    associatedtype InteractionReturnType = String

    /// How the game interfaces with this player.
    var interfacer: UserInterfacer { get }

    /// Creates a new `InteractablePlayer`.
    init(context: RulesType.ContextType, interfacer: UserInterfacer)

    /// Sends some data to the player.
    func send(_ dialog: InteractionInputType)

    /// Gets some input from the user.
    ///
    /// - parameter object: The object to send to the player.
    /// - returns: The input from the user.
    func getInput(_ object: InteractionInputType) -> InteractionReturnType
}
