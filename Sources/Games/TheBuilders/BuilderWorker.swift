//
// Created by Erik Little on 4/2/18.
//

import Foundation
import Kit

/// Represents someone who labors. These guys build stuff.
public protocol Laborer : BuildersPlayable {
    /// The skill of this laborer.
    var skill: SkillType { get }

    /// The skill of this laborer. This controls how productive and the quality of their work.
    var skillLevel: Double { get set }
}

/// The type of a worker.
public enum SkillType : String, Encodable, RandomCasable {
    // TODO replace when this is first class in Swift
    /// All BuildingBlockType cases
    public static let allCases: [SkillType] = [.electrician, .foreman, .painter, .metalWorker, .fitter]

    /// A special skill that is a placeholder for all skills.
    case any

    /// A metal worker. These guys bend metal and stuff.
    case metalWorker

    /// An electrician. These guys install wiring and lights.
    case electrician

    /// A painter. These guys make things pretty.
    case painter

    /// A foreman. These guys make other workers more productive.
    case foreman

    /// A fitter. These guys work with finer things like windows and paneling.
    case fitter
}

/// Represents a worker. These guys build stuff.
public struct Worker : Laborer {
    /// The type of this playable.
    public let playType = BuildersPlayType.worker

    /// The id of this worker.
    public let id = UUID()

    /// The skill of this laborer.
    public let skill: SkillType

    /// The skill of this laborer. This controls how productive and the quality of their work.
    public var skillLevel = 1.0

    /// Returns whether or not this playable can be played by player.
    ///
    /// - parameter inContext: The context this playable is being used in.
    /// - parameter byPlayer: The player playing.
    public func canPlay(inContext context: BuildersBoard, byPlayer player: BuilderPlayer) -> Bool {
        // Workers are always playable
        return true
    }

    /// Creates a random worker.
    public static func getInstance() -> Worker {
        return Worker(skill: .randomCase, skillLevel: 1.0)
    }
}

extension Worker : CustomStringConvertible {
    public var description: String {
        return "Worker(skill: \(skill), skillLevel: \(skillLevel))"
    }
}

extension Array where Element == Worker {
    var allSkills: [SkillType] {
        return map({ $0.skill })
    }

    /// Only those workers that are active on the job.
    func active(accountingFor accidents: [Accident]) -> [Worker] {
        return filter({worker in
            return accidents.reduce(true, {cur, accident in
                return cur && !accident.affectsPlayable(worker)
            })
        })
    }
}
