//
//  AvatarOverviewViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift

class AvatarOverviewViewController: BaseUIViewController, UIScrollViewDelegate {
    
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
    @IBOutlet weak var animalTailView: AvatarOverviewItemView!
    @IBOutlet weak var wheelchairView: AvatarOverviewItemView!
    @IBOutlet weak var animalEarsView: AvatarOverviewItemView!
    @IBOutlet weak var backgroundView: AvatarOverviewItemView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let topHeaderNavigationController = navigationController as? TopHeaderViewController {
            topHeaderCoordinator = TopHeaderCoordinator(topHeaderNavigationController: topHeaderNavigationController, scrollView: scrollView)
        }
        topHeaderCoordinator?.followScrollView = false
        
        setupItemViews()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.configure(user: user)
        }).start())
        
        view.setNeedsLayout()
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        bodySizeLabel.textColor = theme.primaryTextColor
        if theme.isDark {
            containerview.backgroundColor = .gray10
        } else {
            containerview.backgroundColor = theme.offsetBackgroundColor
        }
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.avatar
        bodySizeLabel.text = L10n.bodySize
        bodySizeControl.setTitle(L10n.slim, forSegmentAt: 0)
        bodySizeControl.setTitle(L10n.broad, forSegmentAt: 1)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        topHeaderCoordinator?.scrollViewDidScroll()
    }
    
    private func setupItemViews() {
        shirtView.setup(title: L10n.Avatar.shirt) {[weak self] in
            self?.openDetailView(type: "shirt")
        }
        skinView.setup(title: L10n.Avatar.skin) {[weak self] in
            self?.openDetailView(type: "skin")
        }
        hairColorView.setup(title: L10n.Avatar.hairColor) {[weak self] in
            self?.openDetailView(type: "hair", group: "color")
        }
        hairBangsView.setup(title: L10n.Avatar.bangs) {[weak self] in
            self?.openDetailView(type: "hair", group: "bangs")
        }
        hairBaseView.setup(title: L10n.Avatar.hairStyle) {[weak self] in
            self?.openDetailView(type: "hair", group: "base")
        }
        hairMustacheView.setup(title: L10n.Avatar.mustache) {[weak self] in
            self?.openDetailView(type: "hair", group: "mustache")
        }
        hairBeardView.setup(title: L10n.Avatar.beard) {[weak self] in
            self?.openDetailView(type: "hair", group: "beard")
        }
        hairFlowerView.setup(title: L10n.Avatar.flower) {[weak self] in
            self?.openDetailView(type: "hair", group: "flower")
        }
        wheelchairView.setup(title: L10n.Avatar.wheelchair) {[weak self] in
            self?.openDetailView(type: "chair")
        }
        animalEarsView.setup(title: L10n.animalEars) {[weak self] in
            self?.openDetailView(type: "headAccessory")
        }
        backgroundView.setup(title: L10n.Avatar.background) {[weak self] in
            self?.openDetailView(type: "background")
        }
        animalTailView.setup(title: L10n.Avatar.animalTails) {[weak self] in
            self?.openDetailView(type: "back")
        }
    }
    
    private func configure(user: UserProtocol) {
        bodySizeControl.selectedSegmentIndex = user.preferences?.size == "slim" ? 0 : 1
        
        if let shirt = user.preferences?.shirt {
            shirtView.configure("icon_\(user.preferences?.size ?? "slim")_shirt_\(shirt)")
        }
        if let skin = user.preferences?.skin {
            skinView.configure("icon_skin_\(skin)")
        }
        if let hairColor = user.preferences?.hair?.color {
            let bangs = user.preferences?.hair?.bangs
            hairColorView.configure("icon_hair_bangs_\(bangs ?? 1)_\(hairColor)")
            if bangs != 0 {
                hairBangsView.configure("icon_hair_bangs_\(bangs ?? 1)_\(hairColor)")
            } else {
                hairBangsView.configure(nil)
            }
            
            if let base = user.preferences?.hair?.base, base != 0 {
                hairBaseView.configure("icon_hair_base_\(base)_\(hairColor)")
            } else {
                hairBaseView.configure(nil)
            }
            
            if let beard = user.preferences?.hair?.beard, beard != 0 {
                hairBeardView.configure("icon_hair_beard_\(beard)_\(hairColor)")
            } else {
                hairBeardView.configure(nil)
            }
            
            if let mustache = user.preferences?.hair?.mustache, mustache != 0 {
                hairMustacheView.configure("icon_hair_mustache_\(mustache)_\(hairColor)")
            } else {
                hairMustacheView.configure(nil)
            }
        }
        
        if let flower = user.preferences?.hair?.flower, flower != 0 {
            hairFlowerView.configure("icon_hair_flower_\(flower)")
        } else {
            hairFlowerView.configure(nil)
        }
        
        if let chair = user.preferences?.chair, chair != "none" {
            wheelchairView.configure("icon_chair_\(chair)")
        } else {
            wheelchairView.configure(nil)
        }
        
        if let outfit = user.preferences?.useCostume ?? false ? user.items?.gear?.costume : user.items?.gear?.equipped {
            if let back = outfit.back {
                animalTailView.configure("shop_\(back)")
            } else {
                animalTailView.configure(nil)
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
        let itemWidth = 76.0
        let itemHeight = itemWidth + 38
        let width = min(view.bounds.size.width - 16, 420)
        containerview.pin.top(50).left((view.bounds.size.width - width) / 2).width(width).height(itemHeight * 3 + (3 * 12))
        let padding = (containerview.bounds.width - 24.0 - (itemWidth*4)) / 3
        scrollView.contentSize = CGSize(width: view.bounds.size.width, height: containerview.bounds.origin.y + containerview.bounds.size.height + 64)
        scrollView.pin.all()
        bodySizeLabel.pin.top(0).left(8).above(of: containerview).sizeToFit(.height)
        bodySizeControl.pin.right(8).top(11)
        
        shirtView.pin.top(12).left(12).width(itemWidth).height(itemHeight)
        skinView.pin.top(12).right(of: shirtView).marginLeft(padding).width(itemWidth).height(itemHeight)
        hairColorView.pin.top(12).right(of: skinView).marginLeft(padding).width(itemWidth).height(itemHeight)
        hairBangsView.pin.top(12).right(of: hairColorView).marginLeft(padding).width(itemWidth).height(itemHeight)
        
        hairBaseView.pin.below(of: shirtView).marginTop(12).left(12).width(itemWidth).height(itemHeight)
        hairMustacheView.pin.below(of: shirtView).marginTop(12).right(of: hairBaseView).marginLeft(padding).width(itemWidth).height(itemHeight)
        hairBeardView.pin.below(of: shirtView).marginTop(12).right(of: hairMustacheView).marginLeft(padding).width(itemWidth).height(itemHeight)
        hairFlowerView.pin.below(of: shirtView).marginTop(12).right(of: hairBeardView).marginLeft(padding).width(itemWidth).height(itemHeight)
        
        wheelchairView.pin.below(of: hairBaseView).marginTop(12).left(12).width(itemWidth).height(itemHeight)
        backgroundView.pin.below(of: hairBaseView).marginTop(12).right(of: wheelchairView).marginLeft(padding).width(itemWidth).height(itemHeight)
        animalEarsView.pin.below(of: hairBaseView).marginTop(12).right(of: backgroundView).marginLeft(padding).width(itemWidth).height(itemHeight)
        animalTailView.pin.below(of: hairBaseView).marginTop(12).right(of: animalEarsView).marginLeft(padding).width(itemWidth).height(itemHeight)
    }
    
    @IBAction func bodySizeChanged(_ sender: Any) {
        disposable.inner.add(userRepository.updateUser(key: "preferences.size", value: bodySizeControl.selectedSegmentIndex == 0 ? "slim" : "broad").observeCompleted {})
    }
    
    private func openDetailView(type: String, group: String? = nil) {
        selectedType = type
        selectedGroup = group
        perform(segue: StoryboardSegue.Main.detailSegue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.detailSegue.rawValue {
            let destination = segue.destination as? AvatarDetailViewController
            destination?.customizationType = selectedType
            destination?.customizationGroup = selectedGroup
        }
    }
}
