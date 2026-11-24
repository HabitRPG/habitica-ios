//
//  InventoryRepositoryTests.swift
//  HabiticaTests
//

import XCTest
import ReactiveSwift
import Habitica_Models
import Habitica_API_Client
import Habitica_Database
@testable import Habitica

private class TestItem: ItemProtocol {
    var key: String?
    var text: String?
    var notes: String?
    var value: Float
    var itemType: String?
    var isSubscriberItem = false
    var eventStart: Date?
    var eventEnd: Date?
    var isValid = true
    var isManaged = false

    init(key: String, type: String, value: Float) {
        self.key = key
        self.itemType = type
        self.value = value
    }
}

class InventoryRepositoryTests: RepositoryTestCase {

    private var repository: InventoryRepository!
    private let stable = StableRepository()
    private var feedback: RecordingFeedback!
    private let userLocal = UserLocalRepository()

    override func setUp() {
        super.setUp()
        feedback = RecordingFeedback()
        repository = InventoryRepository()
        repository.feedback = feedback
    }

    private var balance: Float? { userLocal.getUserAsync(userID)?.balance }

    /// Runs the signal until its request was answered.
    private func run<T>(_ signal: Signal<T, Never>, requests: Int = 1) {
        let disposable = signal.observeValues { _ in }
        waitForRequests(requests)
        drain()
        disposable?.dispose()
    }

    // MARK: Selling

    func testSellShowsGoldAndUpdatesUser() throws {
        try storeFixtureUser()
        stub("POST", "user/sell/eggs/Wolf", data: #"{"balance":5}"#)
        firstValue(repository.sell(item: TestItem(key: "Wolf", type: "eggs", value: 3)))
        drain()
        XCTAssertEqual(feedback.goldEarned, [3])
        XCTAssertEqual(balance, 5)
    }

    func testFailedSellShowsNothing() {
        stub("POST", "user/sell/eggs/Wolf", status: 400, data: "null")
        run(repository.sell(item: TestItem(key: "Wolf", type: "eggs", value: 3)))
        XCTAssertTrue(feedback.nothingShown)
    }

    // MARK: Buying

    func testBuySingleItemToast() {
        stub("POST", "user/buy/potion", data: #"{"hp":50}"#)
        firstValue(repository.buyObject(key: "potion", quantity: 1, price: 25, text: "Health Potion"))
        XCTAssertEqual(feedback.toastTexts, [L10n.purchased("Health Potion")])
        XCTAssertEqual(feedback.haptics, [.success])
        XCTAssertEqual(try requestBody()["quantity"] as? Int, 1)
    }

    func testBuySeveralItemsToast() {
        stub("POST", "user/buy/potion", data: #"{"hp":50}"#)
        firstValue(repository.buyObject(key: "potion", quantity: 3, price: 25, text: "Health Potion"))
        XCTAssertEqual(feedback.toastTexts, [L10n.purchasedAmount(3, "Health Potion")])
    }

    func testArmoireOpensArmoireInsteadOfToast() {
        stub("POST", "user/buy/armoire", data: #"{"armoire":{"type":"gear","dropKey":"head_armoire_x","dropText":"Hat"}}"#)
        firstValue(repository.buyObject(key: "armoire", quantity: 1, price: 100, text: "Armoire"))
        XCTAssertEqual(feedback.armoires.first?.dropKey, "head_armoire_x")
        XCTAssertTrue(feedback.toasts.isEmpty)
    }

    func testArmoireViewCanBeSuppressed() {
        stub("POST", "user/buy/armoire", data: #"{"armoire":{"type":"gear","dropKey":"head_armoire_x"}}"#)
        firstValue(repository.buyObject(key: "armoire", quantity: 1, price: 100, text: "Armoire", openArmoireView: false))
        XCTAssertTrue(feedback.nothingShown)
        XCTAssertEqual(feedback.haptics, [.success])
    }

    func testFailedBuyShowsNothing() {
        stub("POST", "user/buy/potion", status: 401, data: "null")
        let result = firstValue(repository.buyObject(key: "potion", quantity: 1, price: 25, text: "Health Potion"))
        XCTAssertNil(result!)
        XCTAssertTrue(feedback.nothingShown)
        XCTAssertTrue(feedback.haptics.isEmpty)
    }

    // MARK: Purchasing with gems

    func testPurchaseDeductsGemsAndConfirms() throws {
        try storeFixtureUser()
        stub("POST", "user/purchase/eggs/Wolf", data: "{}")
        firstValue(repository.purchaseItem(purchaseType: "eggs", key: "Wolf", value: 3, quantity: 2, text: "Wolf"))
        drain()
        XCTAssertEqual(balance, 20.75 - 0.75)
        XCTAssertEqual(feedback.toastTexts, [L10n.purchasedAmount(2, "Wolf")])
    }

    func testFailedPurchaseKeepsGemsAndShowsNothing() throws {
        try storeFixtureUser()
        stub("POST", "user/purchase/eggs/Wolf", status: 401, data: "null")
        run(repository.purchaseItem(purchaseType: "eggs", key: "Wolf", value: 3, quantity: 1, text: "Wolf"))
        XCTAssertEqual(balance, 20.75)
        XCTAssertTrue(feedback.nothingShown)
    }

    func testOtherPurchasesOnlyConfirmSuccess() {
        stub("POST", "user/buy-quest/dilatory", data: "{}")
        stub("POST", "user/purchase-hourglass/pets/Wolf-Veteran", status: 401, data: "null")
        stub("POST", "user/buy-mystery-set/201901", status: 401, data: "null")
        run(repository.purchaseQuest(key: "dilatory", text: "Dilatory"))
        run(repository.purchaseHourglassItem(purchaseType: "pets", key: "Wolf-Veteran", text: "Veteran Wolf"), requests: 2)
        run(repository.purchaseMysterySet(identifier: "201901", text: "Set"), requests: 3)
        XCTAssertEqual(feedback.toastTexts, [L10n.purchased("Dilatory")])
    }

    // MARK: Pets

    func testHatchingShowsHatchedPet() throws {
        try storeAnimals(["Wolf-Base"])
        stub("POST", "user/hatch/Wolf/Base", data: #"{"pets":{"Wolf-Base":5}}"#)
        firstValue(repository.hatchPet(egg: "Wolf", potion: "Base"))
        drain()
        XCTAssertEqual(feedback.hatchedPets.map(\.pet.key), ["Wolf-Base"])
    }

    func testEquipFromHatchSheetEquipsPet() throws {
        try storeAnimals(["Wolf-Base"])
        stub("POST", "user/hatch/Wolf/Base", data: #"{"pets":{"Wolf-Base":5}}"#)
        stub("POST", "user/equip/pet/Wolf-Base", data: "{}")
        firstValue(repository.hatchPet(egg: "Wolf", potion: "Base"))
        drain()
        feedback.hatchedPets.first?.equip()
        waitForRequests(2)
        XCTAssertEqual(requestedPaths.last, "POST user/equip/pet/Wolf-Base")
    }

    func testFailedHatchShowsNothing() throws {
        try storeAnimals(["Wolf-Base"])
        stub("POST", "user/hatch/Wolf/Base", status: 401, data: "null")
        run(repository.hatchPet(egg: "Wolf", potion: "Base"))
        XCTAssertTrue(feedback.hatchedPets.isEmpty)
    }

    func testFeedingStoresTrainedValue() throws {
        try storeFixtureUser()
        try storeAnimals(["Dragon-Red"])
        stub("POST", "user/feed/Dragon-Red/Meat", data: "25")
        let pet = try XCTUnwrap(firstValue(stable.getPet(key: "Dragon-Red")) ?? nil)
        firstValue(repository.feed(pet: pet, food: "Meat"))
        drain()
        let owned = firstValue(stable.getOwnedPets())?.value.first { $0.key == "Dragon-Red" }
        XCTAssertEqual(owned?.trained, 25)
        XCTAssertTrue(feedback.raisedMounts.isEmpty)
    }

    func testFeedingIntoMountShowsMountSheet() throws {
        try storeFixtureUser()
        try storeAnimals(["Dragon-Red"])
        stub("POST", "user/feed/Dragon-Red/Meat", data: "-1")
        stub("POST", "user/equip/mount/Dragon-Red", data: "{}")
        let pet = try XCTUnwrap(firstValue(stable.getPet(key: "Dragon-Red")) ?? nil)
        firstValue(repository.feed(pet: pet, food: "Meat"))
        drain()
        XCTAssertEqual(feedback.raisedMounts.map(\.pet.key), ["Dragon-Red"])
        feedback.raisedMounts.first?.equip()
        waitForRequests(2)
        XCTAssertEqual(requestedPaths.last, "POST user/equip/mount/Dragon-Red")
    }

    func testSaddleWithoutOwningOneExplains() throws {
        try storeAnimals(["Dragon-Red"])
        stub("POST", "user/feed/Dragon-Red/Saddle", status: 404, data: "null")
        let pet = try XCTUnwrap(firstValue(stable.getPet(key: "Dragon-Red")) ?? nil)
        run(repository.feed(pet: pet, food: "Saddle"))
        XCTAssertEqual(feedback.missingSaddleShown, 1)
    }

    func testOtherMissingFoodDoesNotMentionSaddle() throws {
        try storeAnimals(["Dragon-Red"])
        stub("POST", "user/feed/Dragon-Red/Meat", status: 404, data: "null")
        let pet = try XCTUnwrap(firstValue(stable.getPet(key: "Dragon-Red")) ?? nil)
        run(repository.feed(pet: pet, food: "Meat"))
        XCTAssertEqual(feedback.missingSaddleShown, 0)
    }

    // MARK: Equipment

    func testEquipStoresCurrentPet() throws {
        try storeFixtureUser()
        stub("POST", "user/equip/pet/Wolf-Base", data: #"{"currentPet":"Wolf-Base"}"#)
        firstValue(repository.equip(type: "pet", key: "Wolf-Base"))
        drain()
        XCTAssertEqual(userLocal.getUserAsync(userID)?.items?.currentPet, "Wolf-Base")
    }
}
