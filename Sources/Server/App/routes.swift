//
// Created by Erik Little on 6/9/18.
//

import Foundation
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("/") {req in
        return "Hello, world!"
    }
}

