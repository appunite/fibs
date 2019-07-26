//
//  MockedRoutesRegistrator.swift
//  fibs-core
//
//  Created by Damian Kolasiński on 24/06/2019.
//

import Kitura

public protocol MockedRoutesRegistrator {
    func register(_ route: MockedRoute)
}

public struct MockedRoutesRegistratorImp: MockedRoutesRegistrator {
    private let router: Router
    
    public init(router: Router) {
        self.router = router
    }
    
    public func register(_ route: MockedRoute) {
        switch route.method {
        case .get:
            router.get(
                route.path,
                handler: routerHandler(forRoute: route)
            )
        case .post:
            router.post(
                route.path,
                handler: routerHandler(forRoute: route)
            )
        case .put:
            router.put(
                route.path,
                handler: routerHandler(forRoute: route)
            )
        case .delete:
            router.delete(
                route.path,
                handler: routerHandler(forRoute: route)
            )
        case .patch:
            router.patch(
                route.path,
                handler: routerHandler(forRoute: route)
            )
        default:
            fatalError(
                "Method \(route.method) not implemented."
            )
        }
    }
    
    private func routerHandler(
        forRoute route: MockedRoute
        ) -> RouterHandler {
        return { request, response, next in
            response.statusCode = route.statusCode
            route.headers?.forEach {
                response.headers.append(
                    $0.key,
                    value: $0.value
                )
            }
            
            if let json = route.body as? [String: Any] {
                response.send(json: json)
            } else if let jsonArray = route.body as? [Any] {
                response.send(json: jsonArray)
            }
            
            try response.end()
            next()
        }

    }
}
