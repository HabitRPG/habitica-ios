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
        return localRepository.getOwnedPets(userID: userID ?? currentUserId ?? "")
    }
    
    func getOwnedPets(query: String, userID: String? = nil) -> SignalProducer<ReactiveResults<[OwnedPetProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getOwnedPets(query: query, userID: userID ?? currentUserId ?? "")
    }
    
    func getPets(keys: [String]? = nil) -> SignalProducer<ReactiveResults<[PetProtocol]>, ReactiveSwiftRealmError> {
            return localRepository.getPets(keys: keys)
    }
    
    func getPets(query: String) -> SignalProducer<ReactiveResults<[PetProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getPets(query: query)
    }
    
    func getOwnedMounts(userID: String? = nil) -> SignalProducer<ReactiveResults<[OwnedMountProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getOwnedMounts(userID: userID ?? currentUserId ?? "")
    }
    
    func getOwnedMount(key: String, userID: String? = nil)-> SignalProducer<OwnedMountProtocol?, ReactiveSwiftRealmError> {
        return localRepository.getOwnedMount(key: key, userID: userID ?? currentUserId ?? "")
    }
    
    func getOwnedMounts(query: String, userID: String? = nil) -> SignalProducer<ReactiveResults<[OwnedMountProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getOwnedMounts(query: query, userID: userID ?? currentUserId ?? "")
    }
    
    func getMounts(keys: [String]? = nil) -> SignalProducer<ReactiveResults<[MountProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getMounts(keys: keys)
    }
    
    func getMounts(query: String) -> SignalProducer<ReactiveResults<[MountProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getMounts(query: query)
    }
}
