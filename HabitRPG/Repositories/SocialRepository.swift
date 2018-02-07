//
//  SocialRepository.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

class SocialRepository: BaseRepository {
    
    @objc
    func getGroup(_ id: String) -> Group? {
        return makeFetchRequest(entityName: "Group", predicate: NSPredicate(format: "id == %@", id))
    }
}
