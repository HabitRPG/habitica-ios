//
//  RetrieveTasksAPICall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class RetrieveTasksAPICall: BaseAPICall<[TaskProtocol]> {
    
    public override init() {
        super.init()
        self.relativeURL = "tasks/user"
    }
    
    override func decode(with decoder: JSONDecoder, data: Data) throws -> [TaskProtocol]? {
        return try decoder.decode([APITask].self, from: data)
    }
}
