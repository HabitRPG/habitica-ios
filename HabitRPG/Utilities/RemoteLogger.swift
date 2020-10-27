//
//  RemoteLogger.swift
//  Shared
//
//  Created by Phillip Thelen on 25.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import FirebaseCrashlytics

@objc
public class RemoteLogger: NSObject {
    public static let shared = RemoteLogger()
    
    public func record(error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }
    
    public func record(name: String, reason: String) {
        let exm = ExceptionModel(name: name, reason: reason)
        Crashlytics.crashlytics().record(exceptionModel: exm)
    }
    
    public func log(format: String, arguments: CVaListPointer) {
        Crashlytics.crashlytics().log(format: format, arguments: arguments)
    }
    
    public func setUserID(_ userID: String?) {
        Crashlytics.crashlytics().setUserID(userID ?? "")
    }
}
