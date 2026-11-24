//
//  APITaskResponseQuest.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 29.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APITaskResponseQuest: TaskResponseQuestProtocol, Decodable {
    var progressDelta: Float = 0
    var collection: Int?
    
    enum CodingKeys: String, CodingKey {
        case progressDelta
        case collection
    }

    // synthesized decoding would require progressDelta and drop collect-quest results that only send collection
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        progressDelta = (try? values.decode(Float.self, forKey: .progressDelta)) ?? 0
        collection = try? values.decode(Int.self, forKey: .collection)
    }
}
