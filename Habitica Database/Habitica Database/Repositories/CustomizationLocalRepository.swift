//
//  CustomizationRepository.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift
import ReactiveSwift

public class CustomizationLocalRepository: ContentLocalRepository {
    
    public func getCustomizations(type: String, group: String?) -> SignalProducer<ReactiveResults<[CustomizationProtocol]>, ReactiveSwiftRealmError> {
        var query = "type == '\(type)'"
        if let group = group {
            query += " && group == '\(group)'"
        }
        return RealmCustomization.findBy(query: query).sorted(key: "key").reactive().map({ (value, changeset) -> ReactiveResults<[CustomizationProtocol]> in
            return (value.map({ (customization) -> CustomizationProtocol in return customization }), changeset)
        })
    }
    
    public func getOwnedCustomizations(userID: String, type: String, group: String?) -> SignalProducer<ReactiveResults<[OwnedCustomizationProtocol]>, ReactiveSwiftRealmError> {
        var query = "userID = '\(userID)' && isOwned == true && type == '\(type)'"
        if let group = group {
            query += " && group == '\(group)'"
        }
        return RealmOwnedCustomization.findBy(query: query).sorted(key: "key").reactive().map({ (customizations, changes) -> ReactiveResults<[OwnedCustomizationProtocol]> in
            return (customizations.map({ (customization) -> OwnedCustomizationProtocol in return customization }), changes)
        })
    }
    
}
