//
// Created by Erik Little on 4/2/18.
//

import Foundation
import Kit

/// Represents a type that can be used to construct the building.
public protocol BuildingBlock : BuildersPlayable {
    /// The type of this building block.
    var blockType: BuildingBlockType { get }
}

/// The kinds of blocks that are available.
public enum BuildingBlockType : String, Encodable, RandomCasable {
    // TODO replace when this is first class in Swift
    /// All BuildingBlockType cases
    public static let allCases: [BuildingBlockType] = [.wiring, .glass, .wood, .metal, .insulation]

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
}

/// A playable material.
public struct Material : BuildingBlock, Encodable {
    /// The type of this playable.
    public let playType = BuildersPlayType.material

    /// The id of this material.
    public let id = UUID()

    /// The type of this building block.
    public let blockType: BuildingBlockType

    /// Returns whether or not this playable can be played by player.
    ///
    /// - parameter inContext: The context this playable is being used in.
    /// - parameter byPlayer: The player playing.
    public func canPlay(inContext context: BuildersBoard, byPlayer player: BuilderPlayer) -> Bool {
        let accidents = context.accidents[player, default: []]
        let activeWorkers = context.cardsInPlay[player, default: []].workers.active(accountingFor: accidents)

        return activeWorkers.allSkills.contains(blockType.skillNeeded)
    }

    public static func getInstance() -> Material {
        return Material(blockType: .randomCase)
    }
}
