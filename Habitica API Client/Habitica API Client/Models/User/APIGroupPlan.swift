//
//  APIGroupPlan.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 29.08.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIGroupPlan: Decodable, GroupPlanProtocol {
    public var id: String?
    public var name: String?
    public var leaderID: String?
    public var summary: String?
}
