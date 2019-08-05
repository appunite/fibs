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

public class MockedRoutesRegistratorImp: MockedRoutesRegistrator {
    private let router: Router
    private var routes: [AnyHashable: MockedRoute] = [:]
    
    public init(router: Router) {
        self.router = router
    }
    
    public func register(_ route: MockedRoute) {
        guard case .none = routes[AnyHashable(route)] else {
            routes[AnyHashable(route)] = route
            return
        }
        routes[AnyHashable(route)] = route
        switch route.method {
        case .get:
            router.get(
                route.path,
                handler: routerHandler(forRouteHash: route)
            )
        case .post:
            router.post(
                route.path,
                handler: routerHandler(forRouteHash: route)
            )
        case .put:
            router.put(
                route.path,
                handler: routerHandler(forRouteHash: route)
            )
        case .delete:
            router.delete(
                route.path,
                handler: routerHandler(forRouteHash: route)
            )
        case .patch:
            router.patch(
                route.path,
                handler: routerHandler(forRouteHash: route)
            )
        default:
            fatalError(
                "Method \(route.method) not implemented."
            )
        }
    }
    
    private func routerHandler(
        forRouteHash routeHash: AnyHashable
        ) -> RouterHandler {
        return { [unowned self] request, response, next in
            let route = self.routes[routeHash]!
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
            } else if let someBody = route.body {
                response.send("\(someBody)")
            }
            
            try response.end()
            next()
        }

    }
}
