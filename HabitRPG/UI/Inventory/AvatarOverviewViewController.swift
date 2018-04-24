//
//  AvatarOverviewViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class AvatarOverviewViewController: HRPGUIViewController {
    
    private let userRepository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    private var selectedType: String?
    private var selectedGroup: String?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bodySizeLabel: UILabel!
    @IBOutlet weak var bodySizeControl: UISegmentedControl!
    
    @IBOutlet weak var containerview: UIView!
    @IBOutlet weak var shirtView: AvatarOverviewItemView!
    @IBOutlet weak var skinView: AvatarOverviewItemView!
    @IBOutlet weak var hairColorView: AvatarOverviewItemView!
    @IBOutlet weak var hairBangsView: AvatarOverviewItemView!
    @IBOutlet weak var hairBaseView: AvatarOverviewItemView!
    @IBOutlet weak var hairMustacheView: AvatarOverviewItemView!
    @IBOutlet weak var hairBeardView: AvatarOverviewItemView!
    @IBOutlet weak var hairFlowerView: AvatarOverviewItemView!
    @IBOutlet weak var eyewearView: AvatarOverviewItemView!
    @IBOutlet weak var wheelchairView: AvatarOverviewItemView!
    @IBOutlet weak var animalEarsView: AvatarOverviewItemView!
    @IBOutlet weak var backgroundView: AvatarOverviewItemView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator = TopHeaderCoordinator(topHeaderNavigationController: hrpgTopHeaderNavigationController(), scrollView: scrollView)
        topHeaderCoordinator.followScrollView = false
        
        setupItemViews()
        
        disposable.inner.add(userRepository.getUser().on(value: { user in
            self.configure(user: user)
        }).start())
    }
    
    private func setupItemViews() {
        shirtView.setup(title: L10n.Avatar.shirt) {
            self.openDetailView(type: "shirt")
        }
        skinView.setup(title: L10n.Avatar.skin) {
            self.openDetailView(type: "skin")
        }
        hairColorView.setup(title: L10n.Avatar.hairColor) {
            self.openDetailView(type: "hair", group: "color")
        }
        hairBangsView.setup(title: L10n.Avatar.bangs) {
            self.openDetailView(type: "hair", group: "bangs")
        }
        hairBaseView.setup(title: L10n.Avatar.hairStyle) {
            self.openDetailView(type: "hair", group: "base")
        }
        hairMustacheView.setup(title: L10n.Avatar.mustache) {
            self.openDetailView(type: "hair", group: "mustache")
        }
        hairBeardView.setup(title: L10n.Avatar.beard) {
            self.openDetailView(type: "hair", group: "beard")
        }
        hairFlowerView.setup(title: L10n.Avatar.flower) {
            self.openDetailView(type: "hair", group: "flower")
        }
        eyewearView.setup(title: L10n.Avatar.glasses) {
            self.openDetailView(type: "eyewear")
        }
        wheelchairView.setup(title: L10n.Avatar.wheelchair) {
            self.openDetailView(type: "wheelchair")
        }
        animalEarsView.setup(title: L10n.Avatar.animalEars) {
            self.openDetailView(type: "shirt")
        }
        backgroundView.setup(title: L10n.Avatar.background) {
            self.openDetailView(type: "background")
        }
    }
    
    private func configure(user: UserProtocol) {
        bodySizeControl.selectedSegmentIndex = user.preferences?.size == "slim" ? 0 : 1
        
        if let shirt = user.preferences?.shirt {
            shirtView.configure("Icon_\(user.preferences?.size ?? "slim")_shirt_\(shirt)")
        }
        if let skin = user.preferences?.skin {
            skinView.configure("Icon_skin_\(skin)")
        }
        if let hairColor = user.preferences?.hair?.color {
            hairColorView.configure("Icon_hair_bangs_1_\(hairColor)")
            if let bangs = user.preferences?.hair?.bangs, bangs != 0 {
                hairBangsView.configure("Icon_hair_bangs_\(bangs)_\(hairColor)")
            } else {
                hairBangsView.configure(nil)
            }
            
            if let base = user.preferences?.hair?.base, base != 0 {
                hairBaseView.configure("Icon_hair_base_\(base)_\(hairColor)")
            } else {
                hairBaseView.configure(nil)
            }
            
            if let beard = user.preferences?.hair?.beard, beard != 0 {
                hairBeardView.configure("Icon_hair_beard_\(beard)_\(hairColor)")
            } else {
                hairBeardView.configure(nil)
            }
            
            if let mustache = user.preferences?.hair?.mustache, mustache != 0 {
                hairBeardView.configure("Icon_hair_mustache_\(mustache)_\(hairColor)")
            } else {
                hairBeardView.configure(nil)
            }
        }
        
        if let flower = user.preferences?.hair?.flower, flower != 0 {
            hairBeardView.configure("Icon_hair_flower_\(flower)")
        } else {
            hairBeardView.configure(nil)
        }
        
        if let chair = user.preferences?.chair, chair != "none" {
            wheelchairView.configure("Icon_chair_\(chair)")
        } else {
            wheelchairView.configure(nil)
        }
        
        if let outfit = user.preferences?.useCostume ?? false ? user.items?.gear?.costume : user.items?.gear?.equipped {
            if let eyewear = outfit.eyewear {
                eyewearView.configure("shop_\(eyewear)")
            } else {
                eyewearView.configure(nil)
            }
            
            if let headAccessory = outfit.headAccessory {
                animalEarsView.configure("shop_\(headAccessory)")
            } else {
                animalEarsView.configure(nil)
            }
        }
        
        if let background = user.preferences?.background {
            backgroundView.configure("icon_background_\(background)")
        } else {
            backgroundView.configure(nil)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layout()
    }
    
    private func layout() {
        let itemWidth = (view.bounds.size.width - (7*8)) / 4
        let itemHeight = itemWidth+36
        containerview.pin.top(54).left(8).width(view.bounds.size.width-16).height(itemHeight*3+(3*8))
        scrollView.contentSize = CGSize(width: view.bounds.size.width, height: containerview.bounds.origin.y + containerview.bounds.size.height)
        bodySizeLabel.pin.top(0).left(8).above(of: containerview).sizeToFit(.height)
        bodySizeControl.pin.right(8).top(11)
        
        shirtView.pin.top(8).left(8).width(itemWidth).height(itemHeight)
        skinView.pin.top(8).right(of: shirtView).marginLeft(8).width(itemWidth).height(itemHeight)
        hairColorView.pin.top(8).right(of: skinView).marginLeft(8).width(itemWidth).height(itemHeight)
        hairBangsView.pin.top(8).right(of: hairColorView).marginLeft(8).width(itemWidth).height(itemHeight)
        
        hairBaseView.pin.below(of: shirtView).marginTop(8).left(8).width(itemWidth).height(itemHeight)
        hairMustacheView.pin.below(of: shirtView).marginTop(8).right(of: hairBaseView).marginLeft(8).width(itemWidth).height(itemHeight)
        hairBeardView.pin.below(of: shirtView).marginTop(8).right(of: hairMustacheView).marginLeft(8).width(itemWidth).height(itemHeight)
        hairFlowerView.pin.below(of: shirtView).marginTop(8).right(of: hairBeardView).marginLeft(8).width(itemWidth).height(itemHeight)
        
        eyewearView.pin.below(of: hairBaseView).marginTop(8).left(8).width(itemWidth).height(itemHeight)
        wheelchairView.pin.below(of: hairBaseView).marginTop(8).right(of: eyewearView).marginLeft(8).width(itemWidth).height(itemHeight)
        animalEarsView.pin.below(of: hairBaseView).marginTop(8).right(of: wheelchairView).marginLeft(8).width(itemWidth).height(itemHeight)
        backgroundView.pin.below(of: hairBaseView).marginTop(8).right(of: animalEarsView).marginLeft(8).width(itemWidth).height(itemHeight)
    }
    
    @IBAction func bodySizeChanged(_ sender: Any) {
        disposable.inner.add(userRepository.updateUser(key: "preferences.size", value: bodySizeControl.selectedSegmentIndex == 0 ? "slim" : "broad").observeCompleted {})
    }
    
    private func openDetailView(type: String, group: String? = nil) {
        self.selectedType = type
        self.selectedGroup = group
        self.perform(segue: StoryboardSegue.Main.detailSegue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.detailSegue.rawValue {
            let destination = segue.destination as? AvatarDetailViewController
            destination?.customizationType = selectedType
            destination?.customizationGroup = selectedGroup
        }
    }
}
