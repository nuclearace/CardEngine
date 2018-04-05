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

    /// Gets some input from the user.
    ///
    /// - parameter withDialog: The text to display to the user.
    /// - returns: The input from the user.
    func getInput(withDialog dialog: String...) -> InteractionType
}

public extension UserInteractive where InteractionType == String {
    public func getInput(withDialog dialog: String...) -> InteractionType {
        for str in dialog {
            print(str)
        }

        return readLine(strippingNewline: true) ?? ""
    }
}
