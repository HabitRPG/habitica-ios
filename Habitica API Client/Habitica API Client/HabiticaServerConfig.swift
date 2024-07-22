//
//  HabiticaServerConfig.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/20/17.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

public class HabiticaServerConfig {
    public static let production = ServerConfiguration(scheme: "https", host: Constants.defaultProdHost, apiRoute: "api/\(Constants.defaultApiVersion)")
    
    public static let staging = ServerConfiguration(scheme: "https", host: "staging.habitica.com.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    
    public static let bat = ServerConfiguration(scheme: "https", host: "bat.habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let frog = ServerConfiguration(scheme: "https", host: "frog.habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let llama = ServerConfiguration(scheme: "https", host: "llama.habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let monkey = ServerConfiguration(scheme: "https", host: "monkey.habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let seal = ServerConfiguration(scheme: "https", host: "seal.habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let shrimp = ServerConfiguration(scheme: "https", host: "shrimp.habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let star = ServerConfiguration(scheme: "https", host: "star.habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let turtle = ServerConfiguration(scheme: "https", host: "turtle.habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")


    public static let localhost = ServerConfiguration(scheme: "http", host: "192.168.178.52:3000", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let stub = ServerConfiguration(shouldStub: true, scheme: "https", host: "habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    
    public static var current = production
        
    public static var etags: [String: String] = [:]
    
    public static var stubs = [String: CallStub]()
    
    public static func from(_ configName: String) -> ServerConfiguration {
        switch configName {
        case "staging":
            return HabiticaServerConfig.staging
        case "bat":
            return HabiticaServerConfig.bat
        case "frog":
            return HabiticaServerConfig.frog
        case "llama":
            return HabiticaServerConfig.llama
        case "monkey":
            return HabiticaServerConfig.monkey
        case "seal":
            return HabiticaServerConfig.seal
        case "shrimp":
            return HabiticaServerConfig.shrimp
        case "star":
            return HabiticaServerConfig.star
        case "turtle":
            return HabiticaServerConfig.turtle
        default:
            return HabiticaServerConfig.production
        }
    }
}
