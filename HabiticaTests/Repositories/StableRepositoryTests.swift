//
//  StableRepositoryTests.swift
//  HabiticaTests
//

import XCTest
import ReactiveSwift
import Habitica_Models
@testable import Habitica

class StableRepositoryTests: RepositoryTestCase {

    private var repository: StableRepository!

    override func setUp() {
        super.setUp()
        repository = StableRepository()
    }

    func testOwnedPetsAreThoseWithTrainingProgress() throws {
        try storeFixtureUser()
        let owned = try XCTUnwrap(firstValue(repository.getOwnedPets())?.value)
        XCTAssertFalse(owned.isEmpty)
        XCTAssertTrue(owned.allSatisfy { $0.trained > 0 })
        XCTAssertTrue(owned.contains { $0.key == "Dragon-Red" })
    }

    func testOwnedAnimalsBelongToRequestedUser() throws {
        try storeFixtureUser()
        XCTAssertEqual(firstValue(repository.getOwnedPets(userID: "someone-else"))?.value.count, 0)
        XCTAssertEqual(firstValue(repository.getOwnedMounts(userID: "someone-else"))?.value.count, 0)
    }

    func testOwnedMounts() throws {
        try storeFixtureUser()
        let mounts = try XCTUnwrap(firstValue(repository.getOwnedMounts())?.value)
        XCTAssertTrue(mounts.contains { $0.key == "BearCub-Base" })
        XCTAssertTrue(mounts.allSatisfy(\.owned))
        let mount = firstValue(repository.getOwnedMount(key: "Dragon-Red")) ?? nil
        XCTAssertEqual(mount?.key, "Dragon-Red")
    }

    func testPetLookupByKey() throws {
        try storeAnimals(["Wolf-Base", "Fox-Red"])
        let pet = firstValue(repository.getPet(key: "Fox-Red")) ?? nil
        XCTAssertEqual(pet?.egg, "Fox")
        XCTAssertEqual(pet?.potion, "Red")
        XCTAssertNil(firstValue(repository.getPet(key: "Missing-Pet")) ?? nil)
    }

    func testPetsAreSortedByKey() throws {
        try storeAnimals(["Wolf-Base", "Fox-Red", "BearCub-Base"])
        XCTAssertEqual(firstValue(repository.getPets())?.value.compactMap(\.key), ["BearCub-Base", "Fox-Red", "Wolf-Base"])
        XCTAssertEqual(firstValue(repository.getPets(keys: ["Wolf-Base", "Fox-Red"]))?.value.compactMap(\.key), ["Fox-Red", "Wolf-Base"])
    }

    func testMountLookup() throws {
        try storeAnimals(["Wolf-Base"])
        let mount = firstValue(repository.getMount(key: "Wolf-Base")) ?? nil
        XCTAssertEqual(mount?.key, "Wolf-Base")
        XCTAssertEqual(firstValue(repository.getMounts(query: "egg == 'Wolf'"))?.value.count, 1)
    }
}
