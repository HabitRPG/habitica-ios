//
//  ChallengeTableViewControllerTests.swift
//  Habitica
//
//  Created by Phillip Thelen on 19/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import XCTest
@testable import Habitica
import Nimble

class ChallengeTableViewControllerTests: HabiticaTests {
    
    let viewController = (UIStoryboard(name: "Social", bundle: Bundle(identifier: Bundle.main.bundleIdentifier!))
        .instantiateViewController(withIdentifier: "ChallengeTableViewController") as? ChallengeTableViewController)!
    
    override func setUp() {
        super.setUp()
        self.initializeCoreDataStorage()
        let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: HRPGManager.shared().getManagedObjectContext()) as! User
        user.id = "userId"
        HRPGManager.shared().user = user
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUserChallengesPredicate() {
        expect(self.viewController.assemblePredicateString()) == "user.id == 'userId'"
    }
    
    func testChallengesPredicate() {
        self.viewController.showOnlyUserChallenges = false
        expect(self.viewController.assemblePredicateString()).to(beNil())
    }
    
    func testSearchPredicate() {
        viewController.searchText = "name"
        expect(self.viewController.assemblePredicateString()) == "((name CONTAINS[cd] 'name') OR (notes CONTAINS[cd] 'name')) && user.id == 'userId'"
    }
    
    func testOwnedPredicate() {
        viewController.showOnlyUserChallenges = false
        viewController.showOwned = true
        viewController.showNotOwned = false
        expect(self.viewController.assemblePredicateString()) == "leaderId == 'userId'"
    }
    
    func testNotOwnedPredicate() {
        viewController.showOnlyUserChallenges = false
        viewController.showOwned = false
        viewController.showNotOwned = true
        expect(self.viewController.assemblePredicateString()) == "leaderId != 'userId'"
    }
    
    func testOneGuildPredicate() {
        viewController.showOnlyUserChallenges = false
        viewController.shownGuilds = ["id1"]
        expect(self.viewController.assemblePredicateString()) == "group.id IN {'id1'}"
    }
    
    func testMultipleGuildPredicate() {
        viewController.showOnlyUserChallenges = false
        viewController.shownGuilds = ["id1", "id2", "id3"]
        expect(self.viewController.assemblePredicateString()) == "group.id IN {'id1', 'id2', 'id3'}"
    }
    
    func testComplexSearchPredicate() {
        viewController.showOnlyUserChallenges = true
        viewController.showOwned = false
        viewController.showNotOwned = true
        viewController.shownGuilds = ["id1", "id2", "id3"]
        viewController.searchText = "name"
        expect(self.viewController.assemblePredicateString()) == "leaderId != 'userId' && group.id IN {'id1', 'id2', 'id3'} && ((name CONTAINS[cd] 'name') OR (notes CONTAINS[cd] 'name')) && user.id == 'userId'"
    }
}
