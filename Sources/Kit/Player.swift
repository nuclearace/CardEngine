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

    /// The player's context.
    var context: RulesType.ContextType { get }

    /// The encoder messages should be put through.
    var encoder: JSONEncoder { get }

    /// The decoder messages should be put through.
    var decoder: JSONDecoder { get }

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

extension InteractablePlayer {
    // TODO(inlinable 4.2)
    /// Default implementation for `EventLoopFuture`s.
    ///
    /// This will return a future that will be executed on `context.runLoop`.
    public func getInput<T: Decodable>(
        _ dialog: UserInteraction<InteractionType>
    ) -> InteractionReturnType where InteractionReturnType == EventLoopFuture<T> {
        guard let encoded = try? encoder.encode(dialog) else {
            fatalError("Error creating JSON")
        }

        let p: EventLoopPromise<String> = context.runLoop.newPromise()

        interfacer.getInput(withDialog: String(data: encoded, encoding: .utf8)!, withPromise: p)

        return p.futureResult.thenThrowing({[decoder = self.decoder] str in
            guard let data = str.data(using: .utf8) else { throw GameError.badInput }

            return try decoder.decode(T.self, from: data)
        })
    }

    /// Default implementation.
    public func send(_ dialog: UserInteraction<InteractionType>) {
        guard let encoded = try? encoder.encode(dialog) else {
            fatalError("Error creating JSON")
        }

        interfacer.send(String(data: encoded, encoding: .utf8)!)
    }
}
