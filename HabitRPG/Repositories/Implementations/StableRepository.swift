//
//  StableRepository.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift
import Result
import Habitica_Database

class StableRepository: BaseRepository<StableLocalRepository> {
    func getOwnedPets(userID: String? = nil) -> SignalProducer<ReactiveResults<[OwnedPetProtocol]>, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (currentUserID) in
            return self?.localRepository.getOwnedPets(userID: userID ?? currentUserID) ?? SignalProducer.empty
        })
    }
    
    func getOwnedPets(query: String, userID: String? = nil) -> SignalProducer<ReactiveResults<[OwnedPetProtocol]>, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (currentUserID) in
            return self?.localRepository.getOwnedPets(query: query, userID: userID ?? currentUserID) ?? SignalProducer.empty
        })
    }
    
    func getPets(keys: [String]? = nil) -> SignalProducer<ReactiveResults<[PetProtocol]>, ReactiveSwiftRealmError> {
            return localRepository.getPets(keys: keys)
    }
    
    func getPets(query: String) -> SignalProducer<ReactiveResults<[PetProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getPets(query: query)
    }
    
    func getOwnedMounts(userID: String? = nil) -> SignalProducer<ReactiveResults<[OwnedMountProtocol]>, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (currentUserID) in
            return self?.localRepository.getOwnedMounts(userID: userID ?? currentUserID) ?? SignalProducer.empty
        })
    }
    
    func getOwnedMount(key: String, userID: String? = nil)-> SignalProducer<OwnedMountProtocol?, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (currentUserID) in
            return self?.localRepository.getOwnedMount(key: key, userID: userID ?? currentUserID) ?? Signal.empty
        })
    }
    
    func getOwnedMounts(query: String, userID: String? = nil) -> SignalProducer<ReactiveResults<[OwnedMountProtocol]>, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (currentUserID) in
            return self?.localRepository.getOwnedMounts(query: query, userID: userID ?? currentUserID) ?? SignalProducer.empty
        })
    }
    
    func getMounts(keys: [String]? = nil) -> SignalProducer<ReactiveResults<[MountProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getMounts(keys: keys)
    }
    
    func getMounts(query: String) -> SignalProducer<ReactiveResults<[MountProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getMounts(query: query)
    }
}
