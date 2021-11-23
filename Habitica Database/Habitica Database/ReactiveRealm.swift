//
//  ReactiveRealm.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import RealmSwift

// swiftlint:disable force_try
public enum ReactiveSwiftRealmError: Error {
    case wrongThread
    case deletedInAnotherThread
    case alreadyExists
}

public enum ReactiveSwiftRealmThread: Error {
    case main
    case background
}

// Realm save closure
public typealias UpdateClosure<T> = (_ object: T) -> Void

// - MARK: Helpers
private func objectAlreadyExists(realm: Realm, object: Object?) -> Bool {
    if let object = object, let primaryKey = type(of: object).primaryKey(), realm.object(ofType: type(of: object), forPrimaryKey: object.value(forKey: primaryKey)) != nil {
        return true
    }
    return false
}

private func addOperation(realm: Realm, object: Object, update: Realm.UpdatePolicy) {
    realm.beginWrite()
    realm.add(object, update: update)
    try! realm.commitWrite()
}

private func addOperation(realm: Realm, objects: [Object], update: Realm.UpdatePolicy) {
    realm.beginWrite()
    realm.add(objects, update: update)
    try! realm.commitWrite()
}

private func deleteOperation(realm: Realm, object: Object) {
    realm.beginWrite()
    realm.delete(object)
    try! realm.commitWrite()
}

private func deleteOperation(realm: Realm, objects: [Object]) {
    realm.beginWrite()
    realm.delete(objects)
    try! realm.commitWrite()
}

public extension ReactiveRealmOperable where Self: Object {
    
    func add(realm: Realm? = nil, update: Realm.UpdatePolicy = .error, thread: ReactiveSwiftRealmThread = .main) -> SignalProducer<(), ReactiveSwiftRealmError> {
        return SignalProducer {[weak self] observer, _ in
            guard let thisSelf = self else {
                return
            }
            switch thread {
            case .main:
                let threadRealm = try! realm ?? Realm()
                if update == .error && objectAlreadyExists(realm: threadRealm, object: thisSelf) {
                    observer.send(error: .alreadyExists)
                    return
                }
                addOperation(realm: threadRealm, object: thisSelf, update: update)
                observer.send(value: ())
                observer.sendCompleted()
            case.background:
                if self?.realm == nil {
                    let object = thisSelf
                    DispatchQueue(label: "background").async {
                        let threadRealm = try! Realm()
                        if update == .error && objectAlreadyExists(realm: threadRealm, object: object) {
                            observer.send(error: .alreadyExists)
                            return
                        }
                        
                        addOperation(realm: threadRealm, object: object, update: update)
                        
                        DispatchQueue.main.async {
                            observer.send(value: ())
                            observer.sendCompleted()
                        }
                    }
                } else {
                    let objectRef = ThreadSafeReference(to: thisSelf)
                    DispatchQueue(label: "background").async {
                        let threadRealm = try! Realm()
                        guard let object = threadRealm.resolve(objectRef) else {
                            observer.send(error: .deletedInAnotherThread)
                            return
                        }
                        if update == .error && objectAlreadyExists(realm: threadRealm, object: object) {
                            observer.send(error: .alreadyExists)
                            return
                        }
                        
                        addOperation(realm: threadRealm, object: object, update: update)
                        
                        DispatchQueue.main.async {
                            observer.send(value: ())
                            observer.sendCompleted()
                        }
                    }
                }
            }
            
        }
    }
    
    func update(realm: Realm? = nil, thread: ReactiveSwiftRealmThread = .main, operation:@escaping UpdateClosure<Self>) -> SignalProducer<(), ReactiveSwiftRealmError> {
        return SignalProducer {[weak self] observer, _ in
            guard let thisSelf = self else {
                return
            }
            if !Thread.isMainThread {
                observer.send(error: .wrongThread)
                return
            }
            switch thread {
            case .main:
                let threadRealm = try! realm ?? Realm()
                threadRealm.beginWrite()
                operation(thisSelf)
                try! threadRealm.commitWrite()
                observer.send(value: ())
                observer.sendCompleted()
            case .background:
                let objectRef = ThreadSafeReference(to: thisSelf)
                DispatchQueue(label: "background").async {
                    let threadRealm = try! Realm()
                    
                    guard let object = threadRealm.resolve(objectRef) else {
                        observer.send(error: .deletedInAnotherThread)
                        return
                    }
                    threadRealm.beginWrite()
                    operation(object)
                    try! threadRealm.commitWrite()
                    DispatchQueue.main.async {
                        observer.send(value: ())
                        observer.sendCompleted()
                    }
                }
            }
            
        }
    }
    
    func delete(realm: Realm? = nil, thread: ReactiveSwiftRealmThread = .main) -> SignalProducer<(), ReactiveSwiftRealmError> {
        return SignalProducer {[weak self] observer, _ in
            guard let thisSelf = self else {
                return
            }
            switch thread {
            case .main:
                let threadRealm = try! realm ?? Realm()
                deleteOperation(realm: threadRealm, object: thisSelf)
                observer.send(value: ())
                observer.sendCompleted()
            case.background:
                if thisSelf.realm == nil {
                    let object = thisSelf
                    DispatchQueue(label: "background").async {
                        let threadRealm = try! Realm()
                        deleteOperation(realm: threadRealm, object: object)
                        
                        DispatchQueue.main.async {
                            observer.send(value: ())
                            observer.sendCompleted()
                        }
                    }
                } else {
                    let objectRef = ThreadSafeReference(to: thisSelf)
                    DispatchQueue(label: "background").async {
                        let threadRealm = try! Realm()
                        guard let object = threadRealm.resolve(objectRef) else {
                            observer.send(error: .deletedInAnotherThread)
                            return
                        }
                        deleteOperation(realm: threadRealm, object: object)
                        
                        DispatchQueue.main.async {
                            observer.send(value: ())
                            observer.sendCompleted()
                        }
                    }
                }
            }
            
        }
    }
    
}

public extension Array where Element: Object {
    func add(realm: Realm? = nil, update: Realm.UpdatePolicy = .error, thread: ReactiveSwiftRealmThread = .main) -> SignalProducer<(), ReactiveSwiftRealmError> {
        return SignalProducer { observer, _ in
            switch thread {
            case .main:
                let threadRealm = try! realm ?? Realm()
                addOperation(realm: threadRealm, objects: self, update: update)
                observer.send(value: ())
                observer.sendCompleted()
            case.background:
                let notStoredReferences = self.filter { $0.realm == nil }
                DispatchQueue(label: "background").async {
                    let threadRealm = try! Realm()
                    addOperation(realm: threadRealm, objects: notStoredReferences, update: update)
                    
                    DispatchQueue.main.async {
                        observer.send(value: ())
                        observer.sendCompleted()
                    }
                }
                
            }
            
        }
    }
    
    func update(realm: Realm? = nil, thread: ReactiveSwiftRealmThread = .main, operation:@escaping UpdateClosure<Array.Element>) -> SignalProducer<(), ReactiveSwiftRealmError> {
        return SignalProducer { observer, _ in
            if !Thread.isMainThread {
                observer.send(error: .wrongThread)
                return
            }
            switch thread {
            case .main:
                let threadRealm = try! realm ?? Realm()
                threadRealm.beginWrite()
                for object in self {
                    operation(object)
                }
                try! threadRealm.commitWrite()
                observer.send(value: ())
                observer.sendCompleted()
            case .background:
                let safeReferences = self.filter { $0.realm != nil }.map { ThreadSafeReference(to: $0) }
                DispatchQueue(label: "background").async {
                    let threadRealm = try! Realm()
                    let safeObjects = safeReferences.flatMap({ safeObject in
                        return threadRealm.resolve(safeObject)
                    })
                    if safeObjects.count != self.count {
                        observer.send(error: .deletedInAnotherThread)
                        return
                    }
                    threadRealm.beginWrite()
                    for object in safeObjects {
                        operation(object)
                    }
                    try! threadRealm.commitWrite()
                    
                    DispatchQueue.main.async {
                        observer.send(value: ())
                        observer.sendCompleted()
                    }
                }
            }
            
        }
    }
    
    func delete(realm: Realm? = nil, thread: ReactiveSwiftRealmThread = .main) -> SignalProducer<(), ReactiveSwiftRealmError> {
        return SignalProducer { observer, _ in
            switch thread {
            case .main:
                let threadRealm = try! realm ?? Realm()
                deleteOperation(realm: threadRealm, objects: self)
                observer.send(value: ())
                observer.sendCompleted()
            case.background:
                let safeReferences = self.filter { $0.realm != nil }.map { ThreadSafeReference(to: $0) }
                DispatchQueue(label: "background").async {
                    let threadRealm = try! Realm()
                    let safeObjects = safeReferences.flatMap({ safeObject in
                        return threadRealm.resolve(safeObject)
                    })
                    if safeObjects.count != self.count {
                        observer.send(error: .deletedInAnotherThread)
                        return
                    }
                    
                    deleteOperation(realm: threadRealm, objects: safeObjects)
                    
                    DispatchQueue.main.async {
                        observer.send(value: ())
                        observer.sendCompleted()
                    }
                }
            }
            
        }
    }
}

public extension ReactiveRealmQueryable where Self: Object {
    static func findBy(key: Any, realm: Realm = try! Realm()) -> SignalProducer<Self?, ReactiveSwiftRealmError> {
        return SignalProducer { observer, _ in
            if !Thread.isMainThread {
                observer.send(error: .wrongThread)
                return
            }
            observer.send(value: realm.object(ofType: Self.self, forPrimaryKey: key))
        }
        
    }
    
    static func findBy(query: String, realm: Realm = try! Realm()) -> SignalProducer<Results<Self>, ReactiveSwiftRealmError> {
        return SignalProducer { observer, _ in
            if !Thread.isMainThread {
                observer.send(error: .wrongThread)
                return
            }
            observer.send(value: realm.objects(Self.self).filter(query))
        }
    }
    
    static func findBy(predicate: NSPredicate, realm: Realm = try! Realm()) -> SignalProducer<Results<Self>, ReactiveSwiftRealmError> {
        return SignalProducer { observer, _ in
            if !Thread.isMainThread {
                observer.send(error: .wrongThread)
                return
            }
            observer.send(value: realm.objects(Self.self).filter(predicate))
        }
    }
    
    static func findAll(realm: Realm = try! Realm()) -> SignalProducer<Results<Self>, ReactiveSwiftRealmError> {
        return SignalProducer { observer, _ in
            if !Thread.isMainThread {
                observer.send(error: .wrongThread)
                return
            }
            observer.send(value: realm.objects(Self.self))
        }
    }
}

public extension SignalProducerProtocol where Value: NotificationEmitter, Error == ReactiveSwiftRealmError {
    
    /**
     Transform Results<T> into a reactive source
     :returns: signal containing updated values and optional ReactiveChangeset when changed
     */
    
    typealias ReactiveResults = (value: Self.Value, changes: ReactiveChangeset?)
    
     func reactive() -> SignalProducer<ReactiveResults, ReactiveSwiftRealmError> {
        return producer.flatMap(.latest) { results -> SignalProducer<ReactiveResults, ReactiveSwiftRealmError> in
            return SignalProducer { observer, lifetime in
                let dispatchQueue = OperationQueue.current?.underlyingQueue ?? DispatchQueue.main
                let notificationToken = results.observe(on: nil) { (changes: RealmCollectionChange) in
                    dispatchQueue.async {
                        switch changes {
                        case .initial:
                            observer.send(value: (value: results, changes: ReactiveChangeset(initial: true, deleted: [], inserted: (0..<results.count).map { $0 }, updated: [])))
                        case .update(let values, let deletes, let inserts, let updates):
                            observer.send(value: (value: values, changes: ReactiveChangeset(initial: false, deleted: deletes, inserted: inserts, updated: updates)))
                        case .error(let error):
                            // An error occurred while opening the Realm file on the background worker thread
                            fatalError("\(error)")
                        }
                    }
                }
                lifetime.observeEnded {
                    notificationToken.invalidate()
                    observer.sendCompleted()
                }
            }
        }
    }
}

public extension SignalProducerProtocol where Value: ObjectNotificationEmitter, Error == ReactiveSwiftRealmError {
    
    /**
     Transform Results<T> into a reactive source
     :returns: signal containing updated values and optional ReactiveChangeset when changed
     */
    
    typealias ReactiveObject = (value: Self.Value, changes: ReactiveChange?)
    
    func reactiveObject() -> SignalProducer<ReactiveObject, ReactiveSwiftRealmError> {
        return producer.flatMap(.latest) {realmObject -> SignalProducer<ReactiveObject, ReactiveSwiftRealmError> in
            return SignalProducer { observer, lifetime in
                observer.send(value: (value: realmObject, changes: nil))
                let dispatchQueue = OperationQueue.current?.underlyingQueue ?? DispatchQueue.main
                let notificationToken = realmObject.observe(keyPaths: nil, on: nil) { change in
                    dispatchQueue.async {
                    switch change {
                    case .change(let properties):
                        observer.send(value: (value: realmObject, changes: ReactiveChange(deleted: false, properties: properties.1)))
                    case .error(let error):
                        fatalError("\(error)")
                    case .deleted:
                        observer.send(value: (value: realmObject, changes: ReactiveChange(deleted: true, properties: [])))
                        observer.sendCompleted()
                    }
                    }
                }
                lifetime.observeEnded {
                    notificationToken.invalidate()
                    observer.sendCompleted()
                }
            }
        }
    }
}

public  extension SignalProducerProtocol where Value: SortableRealmResults, Error == ReactiveSwiftRealmError {
    /**
     Sorts the signal producer of Results<T> using a key an the ascending value
     :param: key key the results will be sorted by
     :param: ascending true if the results sort order is ascending
     :returns: sorted SignalProducer
     */
    func sorted(key: String, ascending: Bool = true) -> SignalProducer<Self.Value, ReactiveSwiftRealmError> {
        return producer.flatMap(.latest) { results in
            return SignalProducer(value: results.sorted(byKeyPath: key, ascending: ascending) as Self.Value) as SignalProducer<Self.Value, ReactiveSwiftRealmError>
        }
    }
    
    func sorted(by: [RealmSwift.SortDescriptor]) -> SignalProducer<Self.Value, ReactiveSwiftRealmError> {
        return producer.flatMap(.latest) { results in
            return SignalProducer(value: results.sorted(by: by) as Self.Value) as SignalProducer<Self.Value, ReactiveSwiftRealmError>
        }
    }
    
    func distinct(by sequence: [String]) -> SignalProducer<Self.Value, ReactiveSwiftRealmError> {
        return producer.map({ (results) in
            return results.distinct(by: sequence) as Self.Value
        })
    }
}

// - MARK: Protocol helpers
extension Object: ReactiveRealmQueryable {}
public  protocol ReactiveRealmQueryable {}

extension Object: ReactiveRealmOperable {}
public  protocol ReactiveRealmOperable: ThreadConfined {}

/**
 `NotificationEmitter` is a faux protocol to allow for Realm's collections to be handled in a generic way.
 
 All collections already include a `addNotificationBlock(_:)` method - making them conform to `NotificationEmitter` just makes it easier to add Reactive methods to them.
 */

public protocol NotificationEmitter {
    
    func observe(on queue: DispatchQueue?,
                        _ block: @escaping (RealmCollectionChange<Self>) -> Void) -> NotificationToken
    
    var count: Int { get }
}

extension Results: NotificationEmitter {
}

public protocol ObjectNotificationEmitter {
    func observe<T: ObjectBase>(keyPaths: [String]?,
                                          on queue: DispatchQueue?,
                                          _ block: @escaping (ObjectChange<T>) -> Void) -> NotificationToken
}

extension Object: ObjectNotificationEmitter {}

/**
 `ReactiveChangeset` is a struct that contains the data about a single realm change set.
 
 It includes the insertions, modifications, and deletions indexes in the data set that the current notification is about.
 */
public struct ReactiveChangeset {
    
    public let initial: Bool
    
    /// the indexes in the collection that were deleted
    public let deleted: [Int]
    
    /// the indexes in the collection that were inserted
    public let inserted: [Int]
    
    /// the indexes in the collection that were modified
    public let updated: [Int]
    
    public init(initial: Bool, deleted: [Int], inserted: [Int], updated: [Int]) {
        self.initial = initial
        self.deleted = deleted
        self.inserted = inserted
        self.updated = updated
    }
}

public struct ReactiveChange {
    public let properties: [PropertyChange]
    public let deleted: Bool
    
    public init(deleted: Bool, properties: [PropertyChange]) {
        self.deleted = deleted
        self.properties = properties
    }
}

public protocol SortableRealmResults {
    
    /**
     Returns a `Results<T>` sorted
     
     - returns: `Results<T>`
     */
    
    func sorted(byKeyPath keyPath: String, ascending: Bool) -> Self
    func sorted(by: [RealmSwift.SortDescriptor]) -> Self
    // swiftlint:disable:next identifier_name
    func distinct(by: [String]) -> Self
}

extension Results: SortableRealmResults {}

public typealias RealmReactiveResults<Value: RealmCollectionValue> = (value: Results<Value>, changes: ReactiveChangeset?)
public typealias ReactiveResults<Value: Collection> = (value: Value, changes: ReactiveChangeset?)

// swiftlint:enable force_try
