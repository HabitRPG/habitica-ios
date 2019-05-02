//
//  BaseRepository.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Database
import ReactiveSwift
import RealmSwift

class BaseRepository<T: BaseLocalRepository>: NSObject {
    
    let localRepository = T.init()
    let disposable = ScopedDisposable(CompositeDisposable())
    var currentUserId: String? {
        return AuthenticationManager.shared.currentUserId
    }
    var currentUserIDProducer: SignalProducer<String?, Never> {
        return AuthenticationManager.shared.currentUserIDProperty.producer
    }
    
    func save(object: Any) {
        if let realmObject = object as? Object {
            localRepository.save(object: realmObject)
        }
    }
}
