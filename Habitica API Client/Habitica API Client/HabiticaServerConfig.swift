//
//  HRPGServerConfig.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/20/17.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Shared
public class HabiticaServerConfig {
    public static let production = ServerConfiguration(scheme: "https", host: Constants.defaultProdHost, apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let staging = ServerConfiguration(scheme: "https", host: "habitrpg-staging.herokuapp.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let beta = ServerConfiguration(scheme: "https", host: "habitrpg-beta.herokuapp.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let gamma = ServerConfiguration(scheme: "https", host: "habitrpg-gamma.herokuapp.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let delta = ServerConfiguration(scheme: "https", host: "habitrpg-delta.herokuapp.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let localhost = ServerConfiguration(scheme: "http", host: "192.168.178.52:3000", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let stub = ServerConfiguration(shouldStub: true, scheme: "https", host: "habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    
    public static var current = production
    
    public static var aws = ServerConfiguration(scheme: "https", host: "s3.amazonaws.com", apiRoute: "habitica-assets/mobileApp/endpoint")
    
    public static var etags: [String: String] = [:]
}
