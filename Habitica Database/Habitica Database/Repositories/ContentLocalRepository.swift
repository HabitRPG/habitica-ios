//
//  ContentLocalRepository.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift
import ReactiveSwift

public class ContentLocalRepository: BaseLocalRepository {
    
    public func save(_ content: ContentProtocol) {
        var newObjects = [Object]()
        content.skills?.forEach({ (skill) in
            newObjects.append(RealmSkill(skill))
        })
        content.food?.forEach({ (food) in
            newObjects.append(RealmFood(food))
        })
        content.eggs?.forEach({ (egg) in
            newObjects.append(RealmEgg(egg))
        })
        content.hatchingPotions?.forEach({ (hatchingPotion) in
            newObjects.append(RealmHatchingPotion(hatchingPotion))
        })
        content.special?.forEach({ (specialItem) in
            newObjects.append(RealmSpecialItem(specialItem))
        })
        content.quests?.forEach({ (quest) in
            newObjects.append(RealmQuest(quest))
        })
        content.gear?.forEach({ (gear) in
            newObjects.append(RealmGear(gear))
        })
        content.faq?.forEach({ (entries) in
            newObjects.append(RealmFAQEntry(entries))
        })
        content.pets?.forEach({ (pet) in
            newObjects.append(RealmPet(pet))
        })
        content.mounts?.forEach({ (mount) in
            newObjects.append(RealmMount(mount))
        })
        content.customizations.forEach({ (customization) in
            newObjects.append(RealmCustomization(customization))
        })
        
        saveMysteryItem()
        
        save(objects: newObjects)
    }
    
    public func saveMysteryItem() {
        let mysteryItem = RealmSpecialItem()
        mysteryItem.key = "inventory_present"
        mysteryItem.text = "Mystery Item"
        mysteryItem.notes = "Each month, subscribers will receive a mystery item. This is usually released about one week before the end of the month."
        mysteryItem.isSubscriberItem = true
        mysteryItem.itemType = "special"
        updateCall { realm in
            realm.add(mysteryItem, update: true)
        }
    }
    
    public func save(_ worldState: WorldStateProtocol) {
        if let realmWorldState = worldState as? RealmWorldState {
            save(object: realmWorldState)
            return
        }
        save(object: RealmWorldState(id: "habitica", state: worldState))
    }
    
    public func getFAQEntries(search searchText: String? = nil) -> SignalProducer<ReactiveResults<[FAQEntryProtocol]>, ReactiveSwiftRealmError> {
        var producer: SignalProducer<Results<RealmFAQEntry>, ReactiveSwiftRealmError>?
        if let text = searchText, !text.isEmpty {
            producer = RealmFAQEntry.findBy(query: "question CONTAINS[cd] '\(text)'")
        } else {
            producer = RealmFAQEntry.findAll()
        }
        // swiftlint:disable:next force_unwrapping
        return producer!.reactive().map({ (value, changeset) -> ReactiveResults<[FAQEntryProtocol]> in
            return (value.map({ (entry) -> FAQEntryProtocol in return entry }), changeset)
        })
    }
    
    public func getFAQEntry(index: Int) -> SignalProducer<FAQEntryProtocol, ReactiveSwiftRealmError> {
        return RealmFAQEntry.findBy(key: index).skipNil().map({ (entry) -> FAQEntryProtocol in
            return entry
        })
    }
    
    public func getSkills(habitClass: String) -> SignalProducer<ReactiveResults<[SkillProtocol]>, ReactiveSwiftRealmError> {
        return RealmSkill.findBy(query: "habitClass == '\(habitClass)'").sorted(key: "level").reactive().map({ (value, changeset) -> ReactiveResults<[SkillProtocol]> in
            return (value.map({ (skill) -> SkillProtocol in return skill }), changeset)
        })
    }
}
