//
// Created by Erik Little on 7/14/18.
//

import Foundation

public enum TTTMark {
    case X
    case O

    var index: Int {
        return self == .X ? 0 : 1
    }

    static prefix func ! (rhs: TTTMark) -> TTTMark {
        switch rhs {
        case .O:
            return .X
        case .X:
            return .O
        }
    }
}

