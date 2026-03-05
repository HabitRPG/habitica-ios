//
//  CategoryNameHelper.swift
//  Habitica
//
//  Created by teanet on 02.08.2025.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import Foundation

enum ChallengeCategory: String, CaseIterable, Identifiable {
    var id: String {
        return self.rawValue
    }
    
	case official = "habitica_official"
    case academics = "academics"
    case advocacyCauses = "advocacy_causes"
    case creativity = "creativity"
    case entertainment = "entertainment"
    case finance = "finance"
    case healthFitness = "health_fitness"
    case hobbiesOccupations = "hobbies_occupations"
    case locationBased = "location_based"
    case mentalHealth = "mental_health"
    case gettingOrganized = "getting_organized"
    case recoverySupportGroups = "recovery_support_groups"
    case selfImprovement = "self_improvement"
    case spirituality = "spirituality"
    case timeManagement = "time_management"

    static func localizedCategoryNameFor(name: String) -> String? {
        return ChallengeCategory(rawValue: name)?.localizedName
    }
    var localizedName: String {
        return switch self {
        case .official:
            L10n.ChallengeCategory.habiticaOfficial
        case .academics:
            L10n.ChallengeCategory.academics
        case .advocacyCauses:
            L10n.ChallengeCategory.advocacyCauses
        case .creativity:
            L10n.ChallengeCategory.creativity
        case .entertainment:
            L10n.ChallengeCategory.entertainment
        case .finance:
            L10n.ChallengeCategory.finance
        case .healthFitness:
            L10n.ChallengeCategory.healthFitness
        case .hobbiesOccupations:
            L10n.ChallengeCategory.hobbiesOccupations
        case .locationBased:
            L10n.ChallengeCategory.locationBased
        case .mentalHealth:
            L10n.ChallengeCategory.mentalHealth
        case .gettingOrganized:
            L10n.ChallengeCategory.gettingOrganized
        case .recoverySupportGroups:
            L10n.ChallengeCategory.recoverySupportGroups
        case .selfImprovement:
            L10n.ChallengeCategory.selfImprovement
        case .spirituality:
            L10n.ChallengeCategory.spirituality
        case .timeManagement:
            L10n.ChallengeCategory.timeManagement
        }
    }
}
