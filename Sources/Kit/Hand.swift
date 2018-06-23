//
// Created by Erik Little on 6/23/18.
//

import Foundation

/// Represents a set of playables.
public struct Hand<PlayableType> {
    /// The maximum number of playables that can be in the hand.
    public var maxPlayables: Int

    /// The playables in this hand.
    public var playables: [PlayableType] {
        didSet {
            assert(playables.count <= maxPlayables, "Too many cards in a hand")
        }
    }

    /// Creates a new hand with the given playables.
    ///
    /// - parameter playables: The playables for this hand.
    /// - parameter maxPlayables: The maximum number of playables that can be in the hand.
    public init(playables: [PlayableType] = [], maxPlayables: Int = Int.max) {
        self.playables = playables
        self.maxPlayables = maxPlayables
    }
}

extension Hand : ExpressibleByArrayLiteral {
    /// Array literal init.
    public init(arrayLiteral elements: PlayableType...) {
        self.init(playables: elements)
    }
}

extension Hand : RandomAccessCollection, MutableCollection {
    /// The start index of this hand.
    public var startIndex: Int {
        return playables.startIndex
    }

    /// The end index of this hand.
    public var endIndex: Int {
        return playables.endIndex
    }

    /// Gets the `n`th playable in this hand.
    public subscript(n: Int) -> PlayableType {
        get {
            return playables[n]
        }

        set {
            playables[n] = newValue
        }
    }
}

extension Hand : RangeReplaceableCollection {
    public init() {
        self.init(playables: [], maxPlayables: Int.max)
    }

    public mutating func replaceSubrange<C>(
        _ subrange: Range<Index>,
        with newElements: C
    ) where C : Collection, Element == C.Element {
        playables.replaceSubrange(subrange, with: newElements)
    }
}

extension Hand : Encodable where PlayableType: Encodable {
    /// Encodes a hand.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        for playable in playables {
            try container.encode(playable)
        }
    }
}
