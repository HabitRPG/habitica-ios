//
//  CustomizationRepository.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Database
import Habitica_Models
import ReactiveSwift

class CustomizationRepository: BaseRepository<CustomizationLocalRepository> {
    
    public func getCustomizations(type: String, group: String?) -> SignalProducer<ReactiveResults<[CustomizationProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getCustomizations(type: type, group: group)
    }
    
}
