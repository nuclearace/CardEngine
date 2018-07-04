//
// Created by Erik Little on 4/3/18.
//

import Foundation
import NIO

/// Represents a user.
public protocol Player : AnyObject, Hashable {
    // MARK: Typealiases

    associatedtype RulesType: GameRules where RulesType.PlayerType == Self

    // MARK: Properties

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

extension Dictionary where Key: Player {
    /// Transforms this dictionary of `Player` into a dictionary of [String: NewValue], where they key is the id of the
    /// player.
    ///
    /// - parameter mappingValues: A function that maps values stored into a new representation.
    /// - returns: A `Dictionary` of `[String: NewValue]` where the key is `Player.id.uuidString`.
    public func byPlayerId<NewValue>(mappingValues map: (Value) -> NewValue) -> [String: NewValue] {
        return reduce(into: [String: NewValue]()) {cur, keyValue in
            cur[keyValue.0.id.uuidString] = map(keyValue.1)
        }
    }
}

/// Says that a type will be able to interface with a user.
public protocol UserInterfacer {
    // MARK: Properties

    /// The promise to the game that some input will be returned.
    var responsePromise: EventLoopPromise<String>? { get }

    // MARK: Methods

    /// Sends a string to the user.
    func send(_ str: String)

    /// Gets some input from this user.
    func getInput(withDialog dialog: String, withPromise promise: EventLoopPromise<String>)
}

/// Protocol that declares the interface for interacting with users
public protocol InteractablePlayer : Player {
    // MARK: Typealiases

    /// The input type.
    associatedtype InteractionType: Encodable

    associatedtype InteractionReturnType = String

    // MARK: Properties

    /// How the game interfaces with this player.
    var interfacer: UserInterfacer { get }

    // MARK: Initializers

    /// Creates a new `InteractablePlayer`.
    init(context: RulesType.ContextType, interfacer: UserInterfacer)

    // MARK: Methods

    /// Sends some data to the player.
    func send(_ dialog: UserInteraction<InteractionType>)

    /// Gets some input from the user.
    ///
    /// - parameter object: The object to send to the player.
    /// - returns: The input from the user.
    func getInput(_ object: UserInteraction<InteractionType>) -> InteractionReturnType
}
