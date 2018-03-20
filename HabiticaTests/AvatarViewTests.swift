//
//  AvatarViewTests.swift
//  HabiticaTests
//
//  Created by Phillip Thelen on 20.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
import Nimble
@testable import Habitica

class AvatarViewTests: HabiticaTests {
    
    private var avatarView = AvatarView(frame: CGRect.zero)
    
    override func setUp() {
        super.setUp()
        recordMode = false
    }
    
    func testRendering() {
        avatarView = AvatarView(frame: CGRect(x: 0, y: 0, width: 140, height: 147))
        avatarView.showMount = true
        avatarView.showPet = true
        avatarView.showBackground = true
        
        let avatar = TestAvatar(background: "yellow",
                                mount: "BearCub-Base",
                                skin: "915533",
                                shirt: "pink",
                                armor: "armor_healer_2",
                                body: "body_special_summer2015Warrior",
                                hairColor: "brown",
                                hairBase: "1",
                                hairBangs: "3",
                                head: "head_armoire_blackCat",
                                headAccessory: "headAccessory_special_spring2015Warrior",
                                pet: "BearCub-CottonCandyBlue",
                                isSleep: true,
                                size: "broad"
                                )
        
        waitUntil(timeout: 5) { (done) in
            self.avatarView.onRenderingFinished = {
                self.FBSnapshotVerifyView(self.avatarView, tolerance: 0.1)
                done()
            }
            self.avatarView.avatar = avatar
        }
    }
    
    func testRenderingHidingMount() {
        avatarView = AvatarView(frame: CGRect(x: 0, y: 0, width: 140, height: 147))
        avatarView.showMount = false
        avatarView.showPet = true
        avatarView.showBackground = true
        
        let avatar = TestAvatar(background: "yellow",
                                mount: "BearCub-Base",
                                skin: "915533",
                                shirt: "pink",
                                armor: "armor_healer_2",
                                body: "body_special_summer2015Warrior",
                                hairColor: "brown",
                                hairBase: "1",
                                hairBangs: "3",
                                head: "head_armoire_blackCat",
                                headAccessory: "headAccessory_special_spring2015Warrior",
                                pet: "FlyingPig-Skeleton",
                                isSleep: true,
                                size: "broad"
        )
        
        waitUntil(timeout: 5) { (done) in
            self.avatarView.onRenderingFinished = {
                self.FBSnapshotVerifyView(self.avatarView, tolerance: 0.1)
                done()
            }
            self.avatarView.avatar = avatar
        }
    }
    
    func testRenderingHidingPet() {
        avatarView = AvatarView(frame: CGRect(x: 0, y: 0, width: 140, height: 147))
        avatarView.showMount = true
        avatarView.showPet = false
        avatarView.showBackground = true
        
        let avatar = TestAvatar(background: "yellow",
                                mount: "BearCub-Base",
                                skin: "915533",
                                shirt: "pink",
                                armor: "armor_healer_2",
                                body: "body_special_summer2015Warrior",
                                hairColor: "brown",
                                hairBase: "1",
                                hairBangs: "3",
                                head: "head_armoire_blackCat",
                                headAccessory: "headAccessory_special_spring2015Warrior",
                                pet: "BearCub-CottonCandyBlue",
                                isSleep: true,
                                size: "broad"
        )
        
        waitUntil(timeout: 5) { (done) in
            self.avatarView.onRenderingFinished = {
                self.FBSnapshotVerifyView(self.avatarView, tolerance: 0.1)
                done()
            }
            self.avatarView.avatar = avatar
        }
    }
    
    func testRenderingFullyEquipped() {
        avatarView = AvatarView(frame: CGRect(x: 0, y: 0, width: 140, height: 147))
        avatarView.showMount = true
        avatarView.showPet = true
        avatarView.showBackground = true
        
        let avatar = TestAvatar(background: "yellow",
                                back: "back_special_snowdriftVeil",
                                skin: "915533",
                                shirt: "pink",
                                armor: "armor_special_fallRogue",
                                body: "body_special_summer2015Warrior",
                                hairColor: "brown",
                                hairBase: "1",
                                hairBangs: "3",
                                eyewear: "eyewear_special_blueTopFrame",
                                head: "head_special_fall2016Rogue",
                                headAccessory: "headAccessory_special_spring2015Warrior",
                                shield: "shield_special_fall2017Warrior",
                                weapon: "weapon_armoire_basicCrossbow",
                                pet: "FlyingPig-Skeleton",
                                isSleep: true,
                                size: "broad"
        )
        
        waitUntil(timeout: 5) { (done) in
            self.avatarView.onRenderingFinished = {
                self.FBSnapshotVerifyView(self.avatarView, tolerance: 0.1)
                done()
            }
            self.avatarView.avatar = avatar
        }
    }
    
    func testRenderingBlankAvatar() {
        avatarView = AvatarView(frame: CGRect(x: 0, y: 0, width: 140, height: 147))
        avatarView.showMount = true
        avatarView.showPet = true
        avatarView.showBackground = true
        
        let avatar = TestAvatar(background: "yellow",
                                skin: "915533",
                                shirt: "pink",
                                hairColor: "brown",
                                hairBase: "19",
                                hairBangs: "1",
                                size: "broad"
        )
        
        waitUntil(timeout: 5) { (done) in
            self.avatarView.onRenderingFinished = {
                self.FBSnapshotVerifyView(self.avatarView, tolerance: 0.1)
                done()
            }
            self.avatarView.avatar = avatar
        }
    }
    
    func testRenderingContributorGear() {
        avatarView = AvatarView(frame: CGRect(x: 0, y: 0, width: 140, height: 147))
        avatarView.showMount = true
        avatarView.showPet = true
        avatarView.showBackground = true
        
        let avatar = TestAvatar(background: "yellow",
                                skin: "f5a76e",
                                shirt: "blue",
                                armor: "armor_special_1",
                                hairColor: "brown",
                                hairBase: "1",
                                hairBangs: "3",
                                head: "head_special_1",
                                shield: "shield_special_1",
                                weapon: "weapon_special_1",
                                size: "broad"
        )
        
        waitUntil(timeout: 5) { (done) in
            self.avatarView.onRenderingFinished = {
                self.FBSnapshotVerifyView(self.avatarView, tolerance: 0.1)
                done()
            }
            self.avatarView.avatar = avatar
        }
    }
    
    func testRenderingWithWheelchair() {
        avatarView = AvatarView(frame: CGRect(x: 0, y: 0, width: 140, height: 147))
        avatarView.showMount = true
        avatarView.showPet = true
        avatarView.showBackground = true
        
        let avatar = TestAvatar(background: "yellow",
                                chair: "black",
                                skin: "915533",
                                shirt: "pink",
                                hairColor: "brown",
                                hairBase: "1",
                                hairBangs: "3",
                                size: "broad"
        )
        
        waitUntil(timeout: 5) { (done) in
            self.avatarView.onRenderingFinished = {
                self.FBSnapshotVerifyView(self.avatarView, tolerance: 0.1)
                done()
            }
            self.avatarView.avatar = avatar
        }
    }
    
    func testRenderingFullyEquippedScaled() {
        avatarView = AvatarView(frame: CGRect(x: 0, y: 0, width: 110, height: 115))
        avatarView.showMount = true
        avatarView.showPet = true
        avatarView.showBackground = true
        
        let avatar = TestAvatar(background: "yellow",
                                back: "back_special_snowdriftVeil",
                                skin: "915533",
                                shirt: "pink",
                                armor: "armor_special_fallRogue",
                                body: "body_special_summer2015Warrior",
                                hairColor: "brown",
                                hairBase: "1",
                                hairBangs: "3",
                                eyewear: "eyewear_special_blueTopFrame",
                                head: "head_special_fall2016Rogue",
                                headAccessory: "headAccessory_special_spring2015Warrior",
                                shield: "shield_special_fall2017Warrior",
                                weapon: "weapon_armoire_basicCrossbow",
                                pet: "FlyingPig-Skeleton",
                                isSleep: true,
                                size: "broad"
        )
        
        waitUntil(timeout: 5) { (done) in
            self.avatarView.onRenderingFinished = {
                self.FBSnapshotVerifyView(self.avatarView, tolerance: 0.1)
                done()
            }
            self.avatarView.avatar = avatar
        }
    }
    
    func testRenderingScaled() {
        avatarView = AvatarView(frame: CGRect(x: 0, y: 0, width: 110, height: 115))
        avatarView.showMount = true
        avatarView.showPet = true
        avatarView.showBackground = true
        
        let avatar = TestAvatar(background: "yellow",
                                mount: "BearCub-Base",
                                skin: "915533",
                                shirt: "pink",
                                armor: "armor_healer_2",
                                body: "body_special_summer2015Warrior",
                                hairColor: "brown",
                                hairBase: "1",
                                hairBangs: "3",
                                head: "head_armoire_blackCat",
                                headAccessory: "headAccessory_special_spring2015Warrior",
                                pet: "BearCub-CottonCandyBlue",
                                isSleep: true,
                                size: "broad"
        )
        
        waitUntil(timeout: 5) { (done) in
            self.avatarView.onRenderingFinished = {
                self.FBSnapshotVerifyView(self.avatarView, tolerance: 0.1)
                done()
            }
            self.avatarView.avatar = avatar
        }
    }
}

class TestAvatar: Avatar {
    var background: String?
    var chair: String?
    var back: String?
    var skin: String?
    var shirt: String?
    var armor: String?
    var body: String?
    var hairColor: String?
    var hairBase: String?
    var hairBangs: String?
    var hairMustache: String?
    var hairBeard: String?
    var eyewear: String?
    var head: String?
    var headAccessory: String?
    var hairFlower: String?
    var shield: String?
    var weapon: String?
    var visualBuff: String?
    var mount: String?
    var knockout: String?
    var pet: String?
    var isSleep: Bool
    var size: String?
    
    init(background: String? = nil,
         mount: String? = nil,
        chair: String? = nil,
        back: String? = nil,
        skin: String? = nil,
        shirt: String? = nil,
        armor: String? = nil,
        body: String? = nil,
        hairColor: String? = nil,
        hairBase: String? = nil,
        hairBangs: String? = nil,
        hairMustache: String? = nil,
        hairBeard: String? = nil,
        eyewear: String? = nil,
        head: String? = nil,
        headAccessory: String? = nil,
        hairFlower: String? = nil,
        shield: String? = nil,
        weapon: String? = nil,
        visualBuff: String? = nil,
        knockout: String? = nil,
        pet: String? = nil,
        isSleep: Bool = false,
        size: String = "") {
        self.background = background
        self.mount = mount
        self.chair = chair
        self.back = back
        self.skin = skin
        self.shirt = shirt
        self.armor = armor
        self.body = body
        self.hairColor = hairColor
        self.hairBase = hairBase
        self.hairBangs = hairBangs
        self.hairMustache = hairMustache
        self.hairBeard = hairBeard
        self.eyewear = eyewear
        self.head = head
        self.headAccessory = headAccessory
        self.hairFlower = hairFlower
        self.shield = shield
        self.weapon = weapon
        self.visualBuff = visualBuff
        self.knockout = knockout
        self.pet = pet
        self.isSleep = isSleep
        self.size = size
    }
}
