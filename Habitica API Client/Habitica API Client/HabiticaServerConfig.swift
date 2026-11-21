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
    
    public static let staging = ServerConfiguration(scheme: "https", host: "staging.habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    
    public static let bat = ServerConfiguration(scheme: "https", host: "bat.habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let frog = ServerConfiguration(scheme: "https", host: "frog.habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let llama = ServerConfiguration(scheme: "https", host: "llama.habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let monkey = ServerConfiguration(scheme: "https", host: "monkey.habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let seal = ServerConfiguration(scheme: "https", host: "seal.habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let shrimp = ServerConfiguration(scheme: "https", host: "shrimp.habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let starfish = ServerConfiguration(scheme: "https", host: "starfish.habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    public static let turtle = ServerConfiguration(scheme: "https", host: "turtle.habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")

    public static let stub = ServerConfiguration(shouldStub: true, scheme: "https", host: "habitica.com", apiRoute: "api/\(Constants.defaultApiVersion)")
    
    public static var current = production
        
    // Read on each call's work queue and written on the main queue, so every access goes through the lock
    private static let etagLock = NSLock()
    private static var etags: [String: String] = [:]

    public static func etag(for url: String) -> String? {
        etagLock.lock()
        defer { etagLock.unlock() }
        return etags[url]
    }

    public static func setEtag(_ etag: String?, for url: String) {
        etagLock.lock()
        defer { etagLock.unlock() }
        etags[url] = etag
    }
    
    public static var stubs = [String: CallStub]()
    
    public static var authHash: String?
    
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
        case "starfish":
            return HabiticaServerConfig.starfish
        case "turtle":
            return HabiticaServerConfig.turtle
        case "custom":
            let customUrl = URL(string: UserDefaults.standard.string(forKey: "customUrl") ?? "")
            let scheme = customUrl?.scheme ?? "https"
            let hostname: String?
            
            if #available(iOS 16.0, *) {
                hostname = customUrl?.host() ?? customUrl?.absoluteString
            } else {
                hostname = customUrl?.host
            }
            
            var host = hostname ?? ""
            if let port = customUrl?.port {
                host = "\(host):\(port)"
            }
            
            if host.isEmpty {
                return HabiticaServerConfig.production
            }
            
            return ServerConfiguration(scheme: scheme, host: host, apiRoute: "api/\(Constants.defaultApiVersion)")
        default:
            return HabiticaServerConfig.production
        }
    }
}
