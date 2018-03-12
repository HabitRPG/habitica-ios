//
//  ContentRepository.swift
//  Habitica
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Database
import Habitica_Models
import Habitica_API_Client
import ReactiveSwift
import Result

class ContentRepository: BaseRepository<ContentLocalRepository> {
    
    func retrieveContent() -> Signal<ContentProtocol?, NoError> {
        let call = RetrieveContentCall()
        call.fire()
        return call.objectSignal.on(value: {[weak self] content in
            if let content = content {
                self?.localRepository.save(content)
            }
        })
    }
    
}
