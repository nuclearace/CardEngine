//
// Created by Erik Little on 4/2/18.
//

import Foundation

/// Represents a playable item in the game.
public protocol Playable {
    // MARK: Properties

    /// Creates a random instance of this playable.
    static func getInstance() -> Self
}

// TODO Make this protocol a refinement of `CaseIterable` in Swift 4.2
/// A mixin-protocol that lets you get a random instance of an enum case
public protocol RandomCasable {
    // MARK: Properties

    // TODO Remove when this protocol is a refinement of `CaseIterable`
    /// The set of cases for this enum
    static var allCases: [Self] { get }

    /// A random case.
    static var randomCase: Self { get }
}

public extension RandomCasable {
    public static var randomCase: Self {
        // FIXME replace with native random in Swift 4.2
        let rand: Int

        #if os(macOS)
            rand = Int(arc4random_uniform(UInt32(allCases.count)))
        #else
            rand = Int(random()) % allCases.count
        #endif

        return allCases[rand]
    }
}

/// Represents a regular deck of 52 playing card.
public struct DefaultPlayingCard : Playable, Codable {
    // MARK: Properties

    /// The `Suit` of this card.
    public var suit: Suit

    /// The value of this card.
    public var value: Value

    // MARK: Initializers

    /// Creates a new `DefaultPlayingCard` of `suit` and `value`
    public init(suit: Suit, value: Value) {
        self.suit = suit
        self.value = value
    }

    // MARK: Methods

    /// Creates a random card.
    ///
    /// **NOTE**: This does respect the odds of pulling a face card vs regular card.
    public static func getInstance() -> DefaultPlayingCard {
        fatalError("Getting random instance of a deck of 52 card doesn't make sense in the face of probabilities")
    }
}

public extension DefaultPlayingCard {
    /// Represents the suits in a deck of cards.
    public enum Suit : String, Codable, RandomCasable {
        /// All suits.
        public static let allCases: [Suit] = [.clubs, .hearts, .diamonds, .spades]

        /// Clubs.
        case clubs

        /// Hearts.
        case hearts

        /// Diamonds.
        case diamonds

        /// Spades.
        case spades
    }

    /// Represents the set of values a default playing card can have
    public enum Value : Codable {
        // MARK: Cases

        /// A pip card.
        case pip(Int)

        /// A Jack.
        case jack

        /// A Queen.
        case queen

        /// A King.
        case king

        /// An Ace.
        case ace

        // MARK: Properties

        /// The face values.
        public static var faces: [Value] {
            return [.jack, .queen, .king, .ace]
        }

        // MARK: Initializers

        /// Initialize from a `Decoder`.
        public init(from decoder: Decoder) throws {
            let con = try decoder.singleValueContainer()

            if let pip = try? con.decode(Int.self) {
                self = .pip(pip)
                return
            }

            switch try? con.decode(String.self) {
            case "jack"?:
                self = .jack
            case "queen"?:
                self = .queen
            case "king"?:
                self = .king
            case "ace"?:
                self = .ace
            case _:
                throw DefaultPlayingCardValueError.badValue
            }
        }

        // MARK: Methods

        /// Encodes this value.
        public func encode(to encoder: Encoder) throws {
            var con = encoder.singleValueContainer()

            switch self {
            case let .pip(value):
                try con.encode(value)
            case .jack:
                try con.encode("jack")
            case .queen:
                try con.encode("queen")
            case .king:
                try con.encode("king")
            case .ace:
                try con.encode("ace")
            }
        }

        private enum DefaultPlayingCardValueError : Error {
            case badValue
        }
    }
}

// TODO can this be made generic to work with any `Playable`?
/// A type that represents a deck. This type controls things like drawing playables and the probability of
/// drawing each type.
public struct Deck {
    /// The cards of this deck.
    public var cards = Deck.buildDeck()

    /// Constructs a new `Deck`. This initializer creates a standard deck of 52 cards, un-shuffled.
    public init() { }

    private static func buildDeck() -> [DefaultPlayingCard] {
        return Suit.allCases.flatMap({suit -> [DefaultPlayingCard] in
            let pips = (2...10).map({ DefaultPlayingCard(suit: suit, value: .pip($0)) })
            let faces = Value.faces.map({ DefaultPlayingCard(suit: suit, value: $0 )})

            return pips + faces
        })
    }

    private typealias Value = DefaultPlayingCard.Value
    private typealias Suit = DefaultPlayingCard.Suit
}
