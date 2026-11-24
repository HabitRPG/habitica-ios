//
//  CustomizationRepositoryTests.swift
//  HabiticaTests
//

import XCTest
import ReactiveSwift
import Habitica_Models
import Habitica_API_Client
import Habitica_Database
@testable import Habitica

class CustomizationRepositoryTests: RepositoryTestCase {

    private var repository: CustomizationRepository!
    private var feedback: RecordingFeedback!
    private let userLocal = UserLocalRepository()

    override func setUp() {
        super.setUp()
        feedback = RecordingFeedback()
        repository = CustomizationRepository()
        repository.feedback = feedback
        let user = try? JSONDecoder().decode(APIUser.self, from: Data(#"{"id":"\#(userID)","balance":10}"#.utf8))
        userLocal.save(user!)
    }

    private var balance: Float? {
        return userLocal.getUserAsync(userID)?.balance
    }

    func testUnlockDeductsGemPriceFromBalance() {
        // the response omits balance, so the local deduction must stick
        stub("POST", "user/unlock", data: #"{"id":"u"}"#)
        firstValue(repository.unlock(path: "hair.color.rainbow", value: 2, text: "Rainbow"))
        drain()
        XCTAssertEqual(balance, 10 - 0.5, "2 gems are 0.5 balance")
        XCTAssertEqual(feedback.toastTexts, [L10n.purchased("Rainbow")])
        XCTAssertEqual(StubURLProtocol.requests.first?.url?.query, "path=hair.color.rainbow")
    }

    func testServerBalanceWinsOverLocalDeduction() {
        stub("POST", "user/unlock", data: #"{"id":"u","balance":3}"#)
        firstValue(repository.unlock(path: "skin.rainbow", value: 2, text: "Rainbow"))
        drain()
        XCTAssertEqual(balance, 3)
    }

    func testFreeUnlockKeepsBalance() {
        stub("POST", "user/unlock", data: #"{"id":"u"}"#)
        firstValue(repository.unlock(path: "shirt.black", value: 0, text: ""))
        drain()
        XCTAssertEqual(balance, 10)
        XCTAssertTrue(feedback.toasts.isEmpty, "free items are not announced as purchases")
    }

    func testFailedUnlockKeepsBalance() {
        stub("POST", "user/unlock", status: 401, data: "null")
        let disposable = repository.unlock(path: "skin.rainbow", value: 2, text: "").observeValues { _ in }
        waitForRequests(1)
        drain()
        disposable?.dispose()
        XCTAssertEqual(balance, 10)
        XCTAssertTrue(feedback.toasts.isEmpty)
    }
}

class SetupCustomizationRepositoryTests: XCTestCase {

    private func user(size: String? = nil, hairColor: String? = nil) throws -> UserProtocol {
        var preferences: [String: Any] = [:]
        if let size = size { preferences["size"] = size }
        if let hairColor = hairColor { preferences["hair"] = ["color": hairColor, "bangs": 1, "base": 1, "beard": 0, "mustache": 0, "flower": 0] }
        let data = try JSONSerialization.data(withJSONObject: ["id": "u", "preferences": preferences])
        return try JSONDecoder().decode(APIUser.self, from: data)
    }

    private func items(_ category: AvatarCustomizationCategory, _ subcategory: AvatarCustomizationSubcategory?, user: UserProtocol) -> [SetupCustomization] {
        return SetupCustomizationRepository.getCustomizations(category: category, subcategory: subcategory, user: user)
    }

    func testSlimUsersGetSlimShirts() throws {
        // regression: compared against "slin", so slim avatars always saw broad shirts
        let slim = items(.body, .shirt, user: try user(size: "slim"))
        XCTAssertEqual(slim.first?.icon, UIImage(named: "creator_slim_shirt_black"))
        let broad = items(.body, .shirt, user: try user(size: "broad"))
        XCTAssertEqual(broad.first?.icon, UIImage(named: "creator_broad_shirt_black"))
    }

    func testShirtsDefaultToBroad() throws {
        let shirts = items(.body, .shirt, user: try user())
        XCTAssertEqual(shirts.map(\.key), ["black", "blue", "green", "pink", "white", "yellow"])
        XCTAssertEqual(shirts.first?.icon, UIImage(named: "creator_broad_shirt_black"))
    }

    func testHairStylesFollowHairColor() throws {
        let bangs = items(.hair, .bangs, user: try user(hairColor: "blond"))
        XCTAssertEqual(bangs[1].icon, UIImage(named: "creator_hair_bangs_1_blond"))
        let ponytails = items(.hair, .ponytail, user: try user(hairColor: "black"))
        XCTAssertEqual(ponytails.map(\.key), ["0", "1", "3"])
        XCTAssertEqual(ponytails[1].icon, UIImage(named: "creator_hair_base_1_black"))
    }

    func testHairStylesDefaultToRed() throws {
        let bangs = items(.hair, .bangs, user: try user())
        XCTAssertEqual(bangs[1].icon, UIImage(named: "creator_hair_bangs_1_red"))
    }

    func testEveryOptionHasAnIconOrColor() throws {
        let user = try user(hairColor: "white")
        let lists: [[SetupCustomization]] = [
            items(.skin, nil, user: user),
            items(.hair, .color, user: user),
            items(.hair, .bangs, user: user),
            items(.hair, .ponytail, user: user),
            items(.extras, .glasses, user: user),
            items(.extras, .flower, user: user),
            items(.body, .shirt, user: user)
        ]
        for list in lists {
            XCTAssertFalse(list.isEmpty)
            for item in list {
                XCTAssertTrue(item.icon != nil || item.color != nil, "\(item.key) has nothing to show")
            }
        }
    }

    func testWheelchairNoneHasNoIcon() throws {
        let chairs = items(.extras, .wheelchair, user: try user())
        XCTAssertEqual(chairs.first?.key, "none")
        XCTAssertNil(chairs.first?.icon)
        XCTAssertTrue(chairs.dropFirst().allSatisfy { $0.icon != nil })
    }

    func testUnsupportedSubcategoriesAreEmpty() throws {
        let user = try user()
        XCTAssertTrue(items(.body, nil, user: user).isEmpty)
        XCTAssertTrue(items(.hair, nil, user: user).isEmpty)
        XCTAssertTrue(items(.extras, nil, user: user).isEmpty)
        XCTAssertTrue(items(.hair, .shirt, user: user).isEmpty)
    }
}
