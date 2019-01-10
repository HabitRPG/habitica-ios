//
//  HRPGServerConfig.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/20/17.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import FunkyNetwork

public class HabiticaServerConfig {
    public static let production = ServerConfiguration(scheme: "https", host: "habitica.com", apiRoute: "api/v4")
    public static let staging = ServerConfiguration(scheme: "https", host: "staging.habitica.com", apiRoute: "api/v4")
    public static let localhost = ServerConfiguration(scheme: "http", host: "192.168.178.55:3000", apiRoute: "api/v4")
    public static let stub = ServerConfiguration(shouldStub: true, scheme: "https", host: "habitica.com", apiRoute: "api/v4")
    
    public static var current = production
    
    public static var aws = ServerConfiguration(scheme: "https", host: "s3.amazonaws.com", apiRoute: "habitica-assets/mobileApp/endpoint")
}
