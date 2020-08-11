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

class ContentRepository: BaseRepository<ContentLocalRepository> {
    
    func retrieveContent(force: Bool = false) -> Signal<ContentProtocol?, Never> {
        return RetrieveContentCall(language: LanguageHandler.getAppLanguage().code, forceLoading: force).objectSignal.on(value: {[weak self] content in
            if let content = content {
                self?.localRepository.save(content)
            }
        })
    }
    
    func retrieveWorldState() -> Signal<WorldStateProtocol?, Never> {
        return RetrieveWorldStateCall().objectSignal.on(value: {[weak self] worldState in
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
    
    func retrieveHallOfContributors() -> Signal<[MemberProtocol]?, Never> {
        return RetrieveHallOfContributorsCall().arraySignal
    }
    
    func retrieveHallOfPatrons() -> Signal<[MemberProtocol]?, Never> {
        return RetrieveHallOfPatronsCall().arraySignal
    }
    
    func clearDatabase() {
        localRepository.clearDatabase()
        ImageManager.clearImageCache()
    }
}
