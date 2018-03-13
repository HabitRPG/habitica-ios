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
        save(objects: content.spells?.map({ (spell) in
            return RealmSpell(spell)
        }))
        save(objects: content.food?.map({ (food) in
            return RealmFood(food)
        }))
        save(objects: content.eggs?.map({ (egg) in
            return RealmEgg(egg)
        }))
        save(objects: content.hatchingPotions?.map({ (hatchingPotion) in
            return RealmHatchingPotion(hatchingPotion)
        }))
        save(objects: content.gear?.map({ (gear) in
            return RealmGear(gear)
        }))
        save(objects: content.faq?.map({ (entries) in
            return RealmFAQEntry(entries)
        }))
    }
    
    public func save(_ worldState: WorldStateProtocol) {
        
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
    
}
