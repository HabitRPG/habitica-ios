//
//  RealmWorldState.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmWorldState: Object, WorldStateProtocol {
    @objc dynamic var id: String?
    @objc dynamic var worldBoss: QuestStateProtocol? {
        get {
            return realmWorldBoss
        }
        set {
            if let newWorldBoss = newValue as? RealmQuestState {
                realmWorldBoss = newWorldBoss
            } else if let newWorldBoss = newValue {
                realmWorldBoss = RealmQuestState(objectID: id, id: id, state: newWorldBoss)
            }
        }
    }
    @objc dynamic var realmWorldBoss: RealmQuestState?
    @objc dynamic var npcImageSuffix: String?
    
    var currentEvent: WorldStateEventProtocol? {
        get {
            return realmCurrentEvent
        }
        set {
            if let newEvent = newValue as? RealmWorldStateEvent {
                realmCurrentEvent = newEvent
                return
            }
            if let newEvent = newValue {
                realmCurrentEvent = RealmWorldStateEvent(event: newEvent)
            }
        }
    }
    @objc dynamic var realmCurrentEvent: RealmWorldStateEvent?
    var events: [WorldStateEventProtocol] {
        get {
            if realmEvents.isInvalidated { return [] }
            return realmEvents.map({ event -> WorldStateEventProtocol in
                return event
            })
        }
        set {
            if realmEvents.isInvalidated { return }
            realmEvents.removeAll()
            newValue.forEach { event in
                if let realmEvent = event as? RealmWorldStateEvent {
                    realmEvents.append(realmEvent)
                } else {
                    realmEvents.append(RealmWorldStateEvent(event: event))
                }
            }
        }
    }
    var realmEvents = List<RealmWorldStateEvent>()
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    var isValid: Bool {
        return !isInvalidated
    }

    convenience init(id: String?, state: WorldStateProtocol) {
        self.init()
        self.id = id
        worldBoss = state.worldBoss
        currentEvent = state.currentEvent
        events = state.events
        npcImageSuffix = state.npcImageSuffix
    }
}

class RealmWorldStateEvent: Object, WorldStateEventProtocol {
    @objc dynamic var eventKey: String?
    @objc dynamic var start: Date?
    @objc dynamic var end: Date?
    @objc dynamic var promo: String?
    @objc dynamic var npcImageSuffix: String?
    @objc dynamic var aprilFools: String?
    @objc dynamic var gear: Bool = false
    
    convenience init(event: WorldStateEventProtocol) {
        self.init()
        eventKey = event.eventKey
        start = event.start
        end = event.end
        promo = event.promo
        npcImageSuffix = event.npcImageSuffix
        aprilFools = event.aprilFools
        gear = event.gear
    }
}
