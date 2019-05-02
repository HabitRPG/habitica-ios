//
//  HRPGServerConfig.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/20/17.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

public class HabiticaServerConfig {
    public static let production = ServerConfiguration(scheme: "https", host: "habitica.com", apiRoute: "api/v4")
    public static let staging = ServerConfiguration(scheme: "https", host: "habitrpg-staging.herokuapp.com", apiRoute: "api/v4")
    public static let beta = ServerConfiguration(scheme: "https", host: "habitrpg-beta.herokuapp.com", apiRoute: "api/v4")
    public static let gamma = ServerConfiguration(scheme: "https", host: "habitrpg-gamma.herokuapp.com", apiRoute: "api/v4")
    public static let delta = ServerConfiguration(scheme: "https", host: "habitrpg-delta.herokuapp.com", apiRoute: "api/v4")
    public static let localhost = ServerConfiguration(scheme: "http", host: "192.168.178.55:3000", apiRoute: "api/v4")
    public static let stub = ServerConfiguration(shouldStub: true, scheme: "https", host: "habitica.com", apiRoute: "api/v4")
    
    public static var current = production
    
    public static var aws = ServerConfiguration(scheme: "https", host: "s3.amazonaws.com", apiRoute: "habitica-assets/mobileApp/endpoint")
}
