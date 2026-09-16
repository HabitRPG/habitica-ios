//
//  ChallengeFormStep.swift
//  
//
//  Created by Phillip Thelen on 10.03.26.
//


import SwiftUI
import Habitica_Models
import ReactiveSwift

enum ChallengeFormStep: CaseIterable {
    case prize
    case info
    case tasks
}