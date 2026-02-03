//
//  ImageSubstitutionManager.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.02.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//

class ImageSubstitutionManager {
    static func substituteSprite(name: String, context: String? = nil) -> String {
        if context == "pets", let petSubs = substitutions["pets"] {
            for substitution in petSubs.keys where name.starts(with: substitution) {
                return petSubs[substitution] ?? name
            }
        }
        return name
    }
    
    static var substitutions = [String: [String: String]]()
}
