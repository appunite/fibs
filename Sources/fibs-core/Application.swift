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
    private let commandLineExecutor: CommandLineExecutor
    
    public init(
        router: Router,
        routesRegistrator: MockedRoutesRegistrator,
        commandLineExecutor: CommandLineExecutor
    ) {
        self.router = router
        self.routesRegistrator = routesRegistrator
        self.commandLineExecutor = commandLineExecutor
    }
    
    public func run() throws {
        registerMockEndpoint()
        registerCommandEndpoint()
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
    
    private static let jsonDecoder = JSONDecoder()
    
    private func registerCommandEndpoint() {
        router.post("/command", handler: { [commandLineExecutor] request, response, next in
            do {
                var data = Data()
                _ = try request.read(into: &data)
                let body = try Application.jsonDecoder.decode(
                    CommandRoute.RequestBody.self,
                    from: data
                )
                let responseBody = try commandLineExecutor.execute(command: body.command)
                response.send(json: CommandRoute.ResponseBody(rawResponse: responseBody))
            } catch let error {
                response.statusCode = .badRequest
                response.send(error.localizedDescription)
            }
            try response.end()
            next()
        })
    }
}
