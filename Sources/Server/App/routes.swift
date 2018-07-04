//
// Created by Erik Little on 6/9/18.
//

import Foundation
import HTTP
import Service
import Vapor

/// Register your application's routes here.
func routes(_ router: Router, _ env: Environment) throws {
    router.get("/") {req in
        return req.redirect(to: "/index.html")
    }

    // TODO figure out how to redirect them to a Builders lobby
    router.get("/builders") {req in
        return req.redirect(to: "/index.html")
    }

    guard !env.isRelease else { return }

    // Setup debug routes

    router.get("js", "dist", "bundle.js") {req in
        return req.redirect(to: "http://localhost:3000/js/dist/bundle.js")
    }
}

