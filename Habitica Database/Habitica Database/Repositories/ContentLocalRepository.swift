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
import Result

public class ContentLocalRepository: BaseLocalRepository {
    
    public func save(_ content: ContentProtocol) {
        var newObjects = [Object]()
        content.spells?.forEach({ (spell) in
            newObjects.append(RealmSpell(spell))
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
        content.quests?.forEach({ (quest) in
            newObjects.append(RealmQuest(quest))
        })
        content.gear?.forEach({ (gear) in
            newObjects.append(RealmGear(gear))
        })
        content.faq?.forEach({ (entries) in
            newObjects.append(RealmFAQEntry(entries))
        })
        save(objects: newObjects)
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
        return producer!.reactive().map({ (value, changeset) -> ReactiveResults<[FAQEntryProtocol]> in
            return (value.map({ (entry) -> FAQEntryProtocol in return entry }), changeset)
        })
    }
    
    public func getFAQEntry(index: Int) -> SignalProducer<FAQEntryProtocol, ReactiveSwiftRealmError> {
        return RealmFAQEntry.findBy(key: index).skipNil().map({ (entry) -> FAQEntryProtocol in
            return entry
        })
    }
    
    public func getSpells() -> SignalProducer<ReactiveResults<[SpellProtocol]>, ReactiveSwiftRealmError> {
        return RealmSpell.findAll().reactive().map({ (value, changeset) -> ReactiveResults<[SpellProtocol]> in
            return (value.map({ (spell) -> SpellProtocol in return spell }), changeset)
        })
    }
}
