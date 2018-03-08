//
//  UserRepository.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import Habitica_Database
import Habitica_API_Client
import ReactiveSwift
import Result

class UserRepository: BaseRepository<UserLocalRepository> {
    
    func retrieveUser() -> Signal<UserProtocol?, NoError> {
        let call = RetrieveUserCall()
        call.fire()
        return call.objectSignal
    }
    
}
