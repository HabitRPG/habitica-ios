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
import Habitica_API_Client
import ReactiveSwift

class CustomizationRepository: BaseRepository<CustomizationLocalRepository> {
    
    private let userLocalRepository = UserLocalRepository()
    
    public func getCustomizations(type: String, group: String?) -> SignalProducer<ReactiveResults<[CustomizationProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getCustomizations(type: type, group: group)
    }
    
    public func getOwnedCustomizations(type: String, group: String?) -> SignalProducer<ReactiveResults<[OwnedCustomizationProtocol]>, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (userID) in
            return self?.localRepository.getOwnedCustomizations(userID: userID, type: type, group: group) ?? SignalProducer.empty
        })
    }
    
    public func unlock(customization: CustomizationProtocol, value: Float) -> Signal<UserProtocol?, Never> {
        let call = UnlockCustomizationsCall(customizations: [customization])
        call.fire()
        return call.objectSignal.on(value: {[weak self] newUser in
            if let userID = self?.currentUserId, let user = newUser {
                self?.userLocalRepository.updateUser(id: userID, balanceDiff: -(value / 4.0))
                self?.userLocalRepository.updateUser(id: userID, updateUser: user)
            }
        })
    }
    
    public func unlock(customizationSet: CustomizationSetProtocol, value: Float) -> Signal<UserProtocol?, Never> {
        let call = UnlockCustomizationsCall(customizations: customizationSet.setItems ?? [])
        call.fire()
        return call.objectSignal.on(value: {[weak self]newUser in
            if let userID = self?.currentUserId, let user = newUser {
                self?.userLocalRepository.updateUser(id: userID, balanceDiff: -(value / 4.0))
                self?.userLocalRepository.updateUser(id: userID, updateUser: user)
            }
        })
    }
    
    public func unlock(gear: GearProtocol, value: Int) -> Signal<UserProtocol?, Never> {
        let call = UnlockGearCall(gear: [gear])
        call.fire()
        return call.objectSignal.on(value: {[weak self]newUser in
            if let userID = self?.currentUserId, let user = newUser {
                self?.userLocalRepository.updateUser(id: userID, balanceDiff: -(Float(value) / 4.0))
                self?.userLocalRepository.updateUser(id: userID, updateUser: user)
            }
        })
    }
}
