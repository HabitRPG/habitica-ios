//
//  RemoteLogger.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.01.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation

class RemoteLogger: HabiticaLogger {    
    override func record(error: Error) {
    }
    
    override func record(name: String, reason: String) {
    }
    
    override func log(format: String, level: LogLevel = .debug, arguments: CVaListPointer) {

    }
    
    public func setUserID(_ userID: String?) {
    }
}
