//
//  APIFlags.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIFlags: FlagsProtocol, Decodable {
    var armoireEmpty: Bool = false
    var cronCount: Int = 0
    var rebirthEnabled: Bool = false
    var communityGuidelinesAccepted: Bool = false
    var hasNewStuff: Bool = false
    var armoireOpened: Bool = false
    var chatRevoked: Bool = false
    var classSelected: Bool = false
    var itemsEnabled: Bool = false
    var tutorials: [TutorialStepProtocol]
    
    enum CodingKeys: String, CodingKey {
        case armoireEmpty
        case cronCount
        case rebirthEnabled
        case communityGuidelinesAccepted
        case hasNewStuff = "newStuff"
        case armoireOpened
        case chatRevoked
        case classSelected
        case itemsEnabled
        case tutorials = "tutorial"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        armoireEmpty = (try? values.decode(Bool.self, forKey: .armoireEmpty)) ?? false
        cronCount = (try? values.decode(Int.self, forKey: .cronCount)) ?? 0
        rebirthEnabled = (try? values.decode(Bool.self, forKey: .rebirthEnabled)) ?? false
        communityGuidelinesAccepted = (try? values.decode(Bool.self, forKey: .communityGuidelinesAccepted)) ?? false
        hasNewStuff = (try? values.decode(Bool.self, forKey: .hasNewStuff)) ?? false
        armoireOpened = (try? values.decode(Bool.self, forKey: .armoireOpened)) ?? false
        chatRevoked = (try? values.decode(Bool.self, forKey: .chatRevoked)) ?? false
        classSelected = (try? values.decode(Bool.self, forKey: .classSelected)) ?? false
        itemsEnabled = (try? values.decode(Bool.self, forKey: .itemsEnabled)) ?? false
        tutorials = []
        try? values.decode([String: [String: Bool]].self, forKey: .tutorials).forEach({ tutorialTypes in
                tutorialTypes.value.forEach({ (key, wasSeen) in
                tutorials.append(APITutorialStep(type: tutorialTypes.key, key: key, wasSeen: wasSeen))
            })
        })
    }
}
