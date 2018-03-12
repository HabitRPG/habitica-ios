//
//  ContentLocalRepository.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

public class ContentLocalRepository: BaseLocalRepository {
    
    public func save(_ content: ContentProtocol) {
        save(objects: content.spells?.map({ (spell) in
            return RealmSpell(spell)
        }))
    }
    
}
