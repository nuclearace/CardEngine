//
// Created by Erik Little on 4/2/18.
//

import Foundation

/// A namespace enum for various game related items.
public enum Game {
    /// An array of all known playables.
    public static var allPlayables: [Playable.Type] {
        return [Worker.self, Material.self]
    }
}
