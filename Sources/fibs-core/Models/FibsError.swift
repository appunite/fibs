//
//  File.swift
//  fibs-core
//
//  Created by Damian Kolasiński on 15/07/2019.
//

import Foundation

struct FibsError: LocalizedError {
    enum Reason {
        case requiredParamMissing(name: String)
        case invalidParamType(expected: String)
    }
    
    let errorDescription: String
    let reason: Reason
    
    var failureReason: String? {
        switch reason {
        case .invalidParamType(let expected):
            return "Invalid parameter passed, should be: \(expected)."
        case .requiredParamMissing(let name):
            return "Required parameter \"\(name)\" missing."
        }
    }
}
