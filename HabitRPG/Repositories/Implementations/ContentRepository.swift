//
//  ContentRepository.swift
//  Habitica
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Database
import Habitica_Models
import Habitica_API_Client
import ReactiveSwift
import Result

class ContentRepository: BaseRepository<ContentLocalRepository> {
    
    func retrieveContent() -> Signal<ContentProtocol?, NoError> {
        let call = RetrieveContentCall()
        call.fire()
        return call.objectSignal.on(value: {[weak self] content in
            if let content = content {
                self?.localRepository.save(content)
            }
        })
    }
    
    func retrieveWorldState() -> Signal<WorldStateProtocol?, NoError> {
        let call = RetrieveWorldStateCall()
        call.fire()
        return call.objectSignal.on(value: {[weak self] worldState in
            if let worldState = worldState {
                self?.localRepository.save(worldState)
            }
        })
    }
    
    func getFAQEntries(search searchText: String? = nil) -> SignalProducer<ReactiveResults<[FAQEntryProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getFAQEntries(search: searchText)
    }
    
    func getFAQEntry(index: Int) -> SignalProducer<FAQEntryProtocol, ReactiveSwiftRealmError> {
        return localRepository.getFAQEntry(index: index)
    }
    
    func getSkills(habitClass: String) -> SignalProducer<ReactiveResults<[SkillProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getSkills(habitClass: habitClass)
    }
    
    func clearDatabase() {
        localRepository.clearDatabase()
        ImageManager.clearImageCache()
    }
}
