//
//  RemoteLogger.swift
//  Shared
//
//  Created by Phillip Thelen on 25.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import FirebaseCrashlytics
import Habitica_Models
import Kingfisher

class RemoteLogger: HabiticaLogger {    
    override func record(error: Error) {
        if error is KingfisherError {
            return
        }
        Crashlytics.crashlytics().record(error: error)
    }
    
    override func record(name: String, reason: String) {
        let exm = ExceptionModel(name: name, reason: reason)
        Crashlytics.crashlytics().record(exceptionModel: exm)
    }
    
    override func log(format: String, level: LogLevel = .debug, arguments: CVaListPointer) {
        if isProduction {
            if level == .warning || level == .error {
                Crashlytics.crashlytics().log(format: format, arguments: arguments)
            }
        } else {
            super.log(format: format, arguments: arguments)
        }
    }
    
    override func log(_ message: String, level: LogLevel = .debug) {
        if isProduction {
            if level == .warning || level == .error {
                Crashlytics.crashlytics().log(message)
            }
        } else {
            super.log(message, level: level)
        }
    }
    
    override func log(_ error: Error) {
        let message = error.localizedDescription
        let level = LogLevel.error
        if isProduction {
            Crashlytics.crashlytics().record(error: error)
        } else {
            super.log(error)
        }
    }
    
    public func setUserID(_ userID: String?) {
        Crashlytics.crashlytics().setUserID(userID ?? "")
    }
}
