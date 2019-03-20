//
//  StableLocalRepository.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift
import ReactiveSwift

public class StableLocalRepository: ContentLocalRepository {
    
    public func getOwnedPets(userID: String) -> SignalProducer<ReactiveResults<[OwnedPetProtocol]>, ReactiveSwiftRealmError> {
        return RealmOwnedPet.findBy(query: "userID == '\(userID)' && trained > 0").reactive().map({ (value, changeset) -> ReactiveResults<[OwnedPetProtocol]> in
            return (value.map({ (item) -> OwnedPetProtocol in return item }), changeset)
        })
    }
    
    public func getOwnedPets(query: String, userID: String) -> SignalProducer<ReactiveResults<[OwnedPetProtocol]>, ReactiveSwiftRealmError> {
        return RealmOwnedPet.findBy(query: "\(query) && userID == '\(userID)'").reactive().map({ (value, changeset) -> ReactiveResults<[OwnedPetProtocol]> in
            return (value.map({ (item) -> OwnedPetProtocol in return item }), changeset)
        })
    }
    
    public func getOwnedMounts(userID: String) -> SignalProducer<ReactiveResults<[OwnedMountProtocol]>, ReactiveSwiftRealmError> {
        return RealmOwnedMount.findBy(query: "userID == '\(userID)' && owned == true").reactive().map({ (value, changeset) -> ReactiveResults<[OwnedMountProtocol]> in
            return (value.map({ (item) -> OwnedMountProtocol in return item }), changeset)
        })
    }
    
    public func getOwnedMounts(query: String, userID: String) -> SignalProducer<ReactiveResults<[OwnedMountProtocol]>, ReactiveSwiftRealmError> {
        return RealmOwnedMount.findBy(query: "\(query) && userID == '\(userID)' && owned == true").reactive().map({ (value, changeset) -> ReactiveResults<[OwnedMountProtocol]> in
            return (value.map({ (item) -> OwnedMountProtocol in return item }), changeset)
        })
    }
    
    public func getOwnedMount(key: String, userID: String) -> SignalProducer<OwnedMountProtocol?, ReactiveSwiftRealmError> {
        return RealmOwnedMount.findBy(query: "key == '\(key)' && userID == '\(userID)' && owned == true").reactive().map({ (value, _) -> OwnedMountProtocol? in
            return value.first
        })
    }
    
    public func getPets(keys: [String]?) -> SignalProducer<ReactiveResults<[PetProtocol]>, ReactiveSwiftRealmError> {
        var producer: SignalProducer<Results<RealmPet>, ReactiveSwiftRealmError>?
        if let keys = keys {
            producer = RealmPet.findBy(predicate: NSPredicate(format: "key IN %@", keys))
        } else {
            producer = RealmPet.findAll()
        }
        // swiftlint:disable:next force_unwrapping
        return producer!.sorted(key: "key").reactive().map({ (value, changeset) -> ReactiveResults<[PetProtocol]> in
            return (value.map({ (item) -> PetProtocol in return item }), changeset)
        })
    }
    
    public func getPets(query: String) -> SignalProducer<ReactiveResults<[PetProtocol]>, ReactiveSwiftRealmError> {
        return RealmPet.findBy(query: query).sorted(key: "key").reactive().map({ (value, changeset) -> ReactiveResults<[PetProtocol]> in
            return (value.map({ (item) -> PetProtocol in return item }), changeset)
        })
    }
    
    public func getMounts(keys: [String]?) -> SignalProducer<ReactiveResults<[MountProtocol]>, ReactiveSwiftRealmError> {
        var producer: SignalProducer<Results<RealmMount>, ReactiveSwiftRealmError>?
        if let keys = keys {
            producer = RealmMount.findBy(predicate: NSPredicate(format: "key IN %@", keys))
        } else {
            producer = RealmMount.findAll()
        }
        // swiftlint:disable:next force_unwrapping
        return producer!.sorted(key: "key").reactive().map({ (value, changeset) -> ReactiveResults<[MountProtocol]> in
            return (value.map({ (item) -> MountProtocol in return item }), changeset)
        })
    }
    
    public func getMounts(query: String) -> SignalProducer<ReactiveResults<[MountProtocol]>, ReactiveSwiftRealmError> {
        return RealmMount.findBy(query: query).sorted(key: "key").reactive().map({ (value, changeset) -> ReactiveResults<[MountProtocol]> in
            return (value.map({ (item) -> MountProtocol in return item }), changeset)
        })
    }
}
