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
    /// The promise to the game that some input will be returned. =
    var responsePromise: EventLoopPromise<String>? { get }

    /// Sends a string to the user.
    func send(_ str: String)

    /// Gets some input from this user.
    func getInput(withDialog dialog: String, withPromise promise: EventLoopPromise<String>)
}

// TODO possibly rename this
/// Protocol that declares the interface for interacting with users
public protocol InteractablePlayer : Player {
    /// The type returned from interactions
    associatedtype InteractionType = String

    /// How the game interfaces with this player.
    var interfacer: UserInterfacer { get }

    /// Prints some dialog to the player.
    func print(_ dialog: String...)

    /// Gets some input from the user.
    ///
    /// - parameter withDialog: The text to display to the user.
    /// - returns: The input from the user.
    func getInput(withDialog dialog: String...) -> InteractionType
}
