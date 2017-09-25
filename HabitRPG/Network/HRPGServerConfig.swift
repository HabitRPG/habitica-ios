//
//  HRPGServerConfig.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/20/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import FunkyNetwork

public class HRPGServerConfig: ServerConfiguration {
    public static let production = ServerConfiguration(scheme: "https", host: "habitica.com", apiRoute: "api/v3")
    public static let staging = ServerConfiguration(scheme: "https", host: "staging.habitica.com", apiRoute: "api/v3")
    public static let dev = ServerConfiguration(scheme: "http", host: "localhost", apiRoute: "api/v3")
    public static let stub = ServerConfiguration(shouldStub: true, scheme: "https", host: "habitica.com", apiRoute: "api/v3")
    
    public static let current = production
    
}
