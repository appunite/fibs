//
//  Dispatcher.swift
//  fibs-core
//
//  Created by Szymon Mrozek on 23/09/2019.
//

import Foundation

public protocol Dispatcher {
    func dispatch(
        afterInterval interval: DispatchTimeInterval,
        work: @escaping () -> Void
    )
}

public struct DispatcherImp: Dispatcher {
    
    public init() {
        
    }
    
    public func dispatch(
        afterInterval interval: DispatchTimeInterval,
        work: @escaping () -> Void
        ) {
        DispatchQueue.global(qos: .userInitiated)
            .asyncAfter(
                deadline: .now() + interval,
                execute: work
            )
    }    
}
