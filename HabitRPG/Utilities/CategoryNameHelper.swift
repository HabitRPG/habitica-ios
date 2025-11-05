//
//  CategoryNameHelper.swift
//  Habitica
//
//  Created by teanet on 02.08.2025.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import Foundation

enum CategoryNameHelper {
	static let official = "habitica_official"

	static func localizedCategoryNameFor(name: String) -> String? {
        return switch name {
        case official:
            L10n.ChallengeCategory.habiticaOfficial
        case "academics":
            L10n.ChallengeCategory.academics
        case "advocacy_causes":
            L10n.ChallengeCategory.advocacyCauses
        case "creativity":
            L10n.ChallengeCategory.creativity
        case "entertainment":
            L10n.ChallengeCategory.entertainment
        case "finance":
            L10n.ChallengeCategory.finance
        case "health_fitness":
            L10n.ChallengeCategory.healthFitness
        case "hobbies_occupations":
            L10n.ChallengeCategory.hobbiesOccupations
        case "location_based":
            L10n.ChallengeCategory.locationBased
        case "mental_health":
            L10n.ChallengeCategory.mentalHealth
        case "getting_organized":
            L10n.ChallengeCategory.gettingOrganized
        case "recovery_support_groups":
            L10n.ChallengeCategory.recoverySupportGroups
        case "self_improvement":
            L10n.ChallengeCategory.selfImprovement
        case "spirituality":
            L10n.ChallengeCategory.spirituality
        case "time_management":
            L10n.ChallengeCategory.timeManagement
        default:
            nil
        }
    }
}
