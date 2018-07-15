//
// Created by Erik Little on 7/14/18.
//

import Foundation
import Kit

public struct TTTInteraction : Encodable {

}

public enum TTTInteractionResponse : Decodable {
    case play(x: Int, y: Int)

    public init(from decoder: Decoder) throws {
        let con = try decoder.container(keyedBy: CodingKeys.self)
        let point = try con.decode(TTTPoint.self, forKey: .play)

        self = .play(x: point.x, y: point.y)
    }

    private enum CodingKeys : CodingKey {
        case play
    }
}

private struct TTTPoint : Codable {
    var x: Int
    var y: Int
}
