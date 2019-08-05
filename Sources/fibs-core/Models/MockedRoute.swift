//
//  MockedRoute.swift
//  fibs-core
//
//  Created by Damian Kolasiński on 24/06/2019.
//

import Foundation
import Kitura

public struct MockedRoute: Hashable {
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
            guard let routerMethod = RouterMethod(rawValue: methodString.uppercased()),
                RouterMethod.supportedMethods.contains(routerMethod) else {
                    let supportedMethodsString = RouterMethod.supportedMethods
                        .map { $0.rawValue }
                        .joined(separator: ", ")
                    throw FibsError(
                        reason: .invalidParamType(
                            expected: "one of \(supportedMethodsString)"
                        )
                    )
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
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(method.rawValue)
    }
    
    public static func == (lhs: MockedRoute, rhs: MockedRoute) -> Bool {
        return lhs.path == rhs.path
        && lhs.method == rhs.method
    }
}

private func extractJSON(from data: Data) throws -> [String: Any] {
    guard data.count > 0 else { throw FibsError(reason: .emptyBody) }
    guard let json = try? JSONSerialization.jsonObject(
        with: data,
        options: []
    ) as? [String: Any] else {
        throw FibsError(reason: .invalidBodyFormat)
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

private extension RouterMethod {
    static var supportedMethods: [RouterMethod] {
        return [.get, .post, .put, .delete, .patch]
    }
}
