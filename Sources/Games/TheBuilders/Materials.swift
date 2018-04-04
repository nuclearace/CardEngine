//
// Created by Erik Little on 4/2/18.
//

import Foundation

/// Represents a type that can be used to construct the building.
public protocol BuildingBlock : BuildersPlayable {
    /// The type of this building block.
    var blockType: BuildingBlockType { get }
}

/// The kinds of blocks that are available.
public enum BuildingBlockType {
    // TODO replace when this is first class in Swift
    /// All BuildingBlockType cases
    public static let allSkills: [BuildingBlockType] = [.wiring, .glass, .wood, .metal, .insulation]

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
        // FIXME replace with native random in Swift X
        let rand: Int

        #if os(macOS)
        rand = Int(arc4random_uniform(UInt32(allSkills.count)))
        #else
        rand = Int(random()) % allSkills.count
        #endif

        return allSkills[rand]
    }
}

/// A playable material.
public struct Material : BuildingBlock {
    public let playType = BuildersPlayType.material

    /// The type of this building block.
    public let blockType: BuildingBlockType

    public static func getInstance() -> Material {
        return Material(blockType: .randomType)
    }
}
