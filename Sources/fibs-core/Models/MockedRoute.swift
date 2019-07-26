//
//  MockedRoute.swift
//  fibs-core
//
//  Created by Damian Kolasiński on 24/06/2019.
//

import Foundation
import Kitura

public struct MockedRoute {
    let path: String
    let statusCode: HTTPStatusCode
    let body: Any?
    let headers: [String: String]?
    let method: RouterMethod
    
    init(data: Data) throws {
        let json = try extractJSON(from: data)
        
        if let methodString = try extractOptionalParam(
            String.self,
            forKey: "method",
            from: json
        ) {
            guard let routerMethod = RouterMethod(rawValue: methodString) else {
                throw FibsError(reason: .invalidParamType(expected: "String"))
            }
            self.method = routerMethod
        } else {
            self.method = .get
        }
        
        self.path = try extractRequiredParam(
            String.self,
            forKey: "path",
            from: json
        )
        self.statusCode = try extractOptionalParam(
            Int.self,
            forKey: "code",
            from: json
        ).flatMap(HTTPStatusCode.init) ?? .OK
        self.body = json["body"]
        self.headers = try extractOptionalParam(
            [String: String].self,
            forKey: "headers",
            from: json
        )
    }
}

private func extractJSON(from data: Data) throws -> [String: Any] {
    let anyJSON = try JSONSerialization.jsonObject(
        with: data,
        options: []
    )
    guard let json = anyJSON as? [String: Any] else {
        throw URLError(.cannotDecodeContentData)
    }
    return json
}

private func extractRequiredParam<Type>(
    _ type: Type.Type,
    forKey key: String,
    from json: [String: Any]
) throws -> Type {
    guard let value = json[key] else {
        throw FibsError(reason: .requiredParamMissing(name: key))
    }
    guard let castedValue = value as? Type else {
        throw FibsError(reason: .invalidParamType(expected: "\(type)"))
    }
    return castedValue
}

private func extractOptionalParam<Type>(
    _ type: Type.Type,
    forKey key: String,
    from json: [String: Any]
) throws -> Type? {
    guard let value = json[key] else { return nil }
    guard let castedValue = value as? Type else {
        throw FibsError(reason: .invalidParamType(expected: "\(type)"))
    }
    return castedValue
}

private extension FibsError {
    init(reason: Reason) {
        self.init(
            errorDescription: "Error when parsing mocked route.",
            reason: reason
        )
    }
}
