//
// Created by Erik Little on 4/3/18.
//

import Foundation

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

// TODO possibly rename this
/// Protocol that declares the interface for interacting with users
public protocol UserInteractive {
    /// The type returned from interactions
    associatedtype InteractionType = String

    /// Prints some dialog to the player
    func print(_ out: String...)

    /// Gets some input from the user.
    ///
    /// - parameter withDialog: The text to display to the user.
    /// - returns: The input from the user.
    func getInput(withDialog dialog: String...) -> InteractionType
}

public extension UserInteractive {
    /// Prints some dialog to the player
    public func print(_ out: String...) {
        for o in out {
            Swift.print(o, terminator: "")
        }
    }
}

public extension UserInteractive where InteractionType == String {
    /// Default implementation. Prints to stdout
    ///
    /// **NOTE**: Newlines are not added to prints.
    ///
    /// - parameter withDialog: The text to display to the user.
    /// - returns: The input from the user.
    public func getInput(withDialog dialog: String...) -> InteractionType {
        for str in dialog {
            Swift.print(str, terminator: "")
        }

        return readLine(strippingNewline: true) ?? ""
    }
}
