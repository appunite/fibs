//
//  main.swift
//  fibs
//
//  Created by Szymon Mrozek on 24/06/2019.
//

import fibs_core
import Kitura

let router = Router()
let routesRegistrator = MockedRoutesRegistratorImp(
    router: router,
    dispatcher: DispatcherImp()
)
let app = Application(
    router: router,
    routesRegistrator: routesRegistrator
)

do {
    try app.run()
} catch {
    debugPrint(error.localizedDescription)
}
