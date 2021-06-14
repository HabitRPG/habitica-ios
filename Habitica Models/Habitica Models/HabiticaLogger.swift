//
//  HabiticaLogger.swift
//  Habitica
//
//  Created by Phillip Thelen on 14.06.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import UIKit

public enum LogLevel {
    case verbose
    case debug
    case info
    case warning
    case error
    
    var emoji: String {
        switch self {
        case .verbose:
            return "◻️"
        case .debug:
            return "🟢"
        case .info:
            return "🔵"
        case .warning:
            return "🔶"
        case .error:
            return "🛑"
        }
    }
    
    var color: UIColor {
        switch self {
        case .verbose:
            return .gray
        case .debug:
            return .green
        case .info:
            return .blue
        case .warning:
            return .orange
        case .error:
            return .red
        }
    }
}

public var logger = HabiticaLogger()

public class HabiticaLogger {
    public var isProduction = true
    private static let formatter: DateFormatter = {
        let logger = DateFormatter()
        logger.dateStyle = .short
        logger.timeStyle = .medium
        return logger
    }()

    public func record(error: Error) {}
    
    public func record(name: String, reason: String) {}
    
    public func log(format: String, level: LogLevel = .debug, arguments: CVaListPointer) {}
    public func log(_ message: String, level: LogLevel = .debug) {
        print("\(level.emoji) \(HabiticaLogger.formatter.string(from: Date())) \(message)")
    }
    public func log(_ error: Error) {
        let message = error.localizedDescription
        let level = LogLevel.error
        print("\(level.emoji) \(HabiticaLogger.formatter.string(from: Date())) \(message)")
    }
}
