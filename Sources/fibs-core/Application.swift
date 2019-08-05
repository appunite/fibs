//
//  Application.swift
//  fibs-core
//
//  Created by Damian Kolasiński on 24/06/2019.
//

import Foundation
import Kitura

public class Application {
    
    private let router: Router
    private let routesRegistrator: MockedRoutesRegistrator
    
    public init(
        router: Router,
        routesRegistrator: MockedRoutesRegistrator
    ) {
        self.router = router
        self.routesRegistrator = MockedRoutesRegistratorImp(router: router)
    }
    
    public func run() throws {
        registerMockEndpoint()
        Kitura.addHTTPServer(onPort: 8080, with: router)
        Kitura.run()
    }
    
    private func registerMockEndpoint() {
        router.post("/mock", handler: { [routesRegistrator] request, response, next in
            var data = Data()
            _ = try request.read(into: &data)
            do {
                let parsedRoute = try MockedRoute(data: data)
                routesRegistrator.register(parsedRoute)
            } catch let error {
                response.statusCode = .badRequest
                response.send(error.localizedDescription)
            }
            try response.end()
            next()
        })
    }
}
