//
//  main.swift
//  fibs-core
//
//  Created by Szymon Mrozek on 24/06/2019.
//

import Foundation
import ShellOut

public protocol CommandLineExecutor {
    func execute(command: String) throws -> String
}

public class CommandLineExecutorImp: CommandLineExecutor {
    public init() { }
    
    public func execute(command: String) throws -> String {
        try shellOut(to: command)
    }
}
