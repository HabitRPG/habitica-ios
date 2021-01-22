//
//  RemoteLogger.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.01.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public class RemoteLogger: NSObject {
    public static let shared = RemoteLogger()
    
    public func record(error: Error) {
        //pass
    }
    
    public func record(name: String, reason: String) {
        //pass
    }
    
    public func log(format: String, arguments: CVaListPointer) {
        //pass
    }
    
    public func setUserID(_ userID: String?) {
        //pass
    }
}
