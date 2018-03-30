//
//  APISkillResponse.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 29.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APISkillResponse: SkillResponseProtocol, Decodable {
    
    public var user: UserProtocol?
    public var task: TaskProtocol?
    
    enum CodingKeys: String, CodingKey {
        case user
        case task
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        user = try? values.decode(APIUser.self, forKey: .user)
        task = try? values.decode(APITask.self, forKey: .task)
    }
}
