//
// Created by Erik Little on 4/2/18.
//

import Foundation

/// Represents a type that can be used to construct the building.
public protocol BuildingBlock : Playable {
    /// The type of this building block.
    var blockType: BuildingBlockType { get }
}

/// The kinds of blocks that are available.
public enum BuildingBlockType {
    /// Windows are a must.
    case glass

    /// No one wants the temp to fluctuate!
    case insulation

    /// Metal. Must be the hardest of metals.
    case metal

    /// Every floor needs some wiring.
    case wiring

    /// Wood? Because all metal fixtures would look dystopian.
    case wood

    /// The skill needed to work with this type
    public var skillNeeded: SkillType {
        switch self {
        case .glass, .wood, .insulation:
            return .fitter
        case .wiring:
            return .electrician
        case .metal:
            return .metalWorker
        }
    }

    /// A random type.
    public static var randomType: BuildingBlockType {
        // FIXME linux
        return [.wiring, .glass, .wood, .metal, .insulation][Int(arc4random_uniform(5))]
    }
}

/// A playable material.
public struct Material : BuildingBlock {
    public let playType = PlayType.material

    /// The type of this building block.
    public let blockType: BuildingBlockType

    public static func getInstance() -> Material {
        return Material(blockType: .randomType)
    }
}
