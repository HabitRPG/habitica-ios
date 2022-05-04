//
//  AvatarSetupViewController.swift
//  Habitica
//
//  Created by Phillip on 01.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift

public enum AvatarCustomizationCategory {
    case body, skin, hair, extras
}

public enum AvatarCustomizationSubcategory {
    case none, size, shirt, bangs, ponytail, color, flower, glasses, wheelchair
    
    var text: String {
        switch self {
        case .size:
            return L10n.size
        case .shirt:
            return L10n.shirt
        case .bangs:
            return L10n.bangs
        case .ponytail:
            return L10n.ponytail
        case .color:
            return L10n.color
        case .flower:
            return L10n.flower
        case .glasses:
            return L10n.glasses
        case .wheelchair:
            return L10n.wheelchair
        default:
            return ""
        }
    }
}

class AvatarSetupViewController: UIViewController, TypingTextViewController, Themeable {

    @IBOutlet weak var bodyButton: UIStackView!
    @IBOutlet weak var bodyImageView: UIImageView!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var skinButton: UIStackView!
    @IBOutlet weak var skinImageView: UIImageView!
    @IBOutlet weak var skinLabel: UILabel!
    @IBOutlet weak var hairButton: UIStackView!
    @IBOutlet weak var hairImageView: UIImageView!
    @IBOutlet weak var hairLabel: UILabel!
    @IBOutlet weak var extrasButton: UIStackView!
    @IBOutlet weak var extrasImageView: UIImageView!
    @IBOutlet weak var extrasLabel: UILabel!
    @IBOutlet weak var selectionCaretOffset: NSLayoutConstraint!
    @IBOutlet weak var speechbubbleView: SpeechbubbleView!
    
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var randomizeButton: UIButton!
    @IBOutlet weak var subCategoryContainer: UIStackView!
    @IBOutlet weak var contentContainer: UIStackView!
    
    @IBOutlet var contentCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var categoryHeight: NSLayoutConstraint!
    @IBOutlet weak var subcategoryIndicatorPosition: NSLayoutConstraint!
    @IBOutlet weak var subcategoryIndicatorWidth: NSLayoutConstraint!
    
    var user: UserProtocol? {
        didSet {
            if user?.isValid != true {
                return
            }
            if let user = self.user {
                avatarView.avatar = AvatarViewModel(avatar: user)
            }
            self.updateActiveCustomizations()
        }
    }
    private let userRepository = UserRepository()
    private let inventoryRepository = InventoryRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    var currentCategory: AvatarCustomizationCategory = .body {
        didSet {
            updateCategoryButtons()
            setSubCategories(getSubcategoriesForCurrentCategory())
            updateContent()
        }
    }
    
    var currentSubcategory: AvatarCustomizationSubcategory = .none {
        didSet {
            updateSubcategoryButtons()
            updateContent()
        }
    }
    var content: [SetupCustomization] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateText()
        ThemeService.shared.addThemeable(themable: self)

        avatarView.showBackground = false
        avatarView.showMount = false
        avatarView.showPet = false
        avatarView.size = .regular
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
        }).start())
        
        let bodyGesture = UITapGestureRecognizer(target: self, action: #selector(setBodyCategory))
        bodyButton.addGestureRecognizer(bodyGesture)
        let skinGesture = UITapGestureRecognizer(target: self, action: #selector(setSkinCategory))
        skinButton.addGestureRecognizer(skinGesture)
        let hairGesture = UITapGestureRecognizer(target: self, action: #selector(setHairCategory))
        hairButton.addGestureRecognizer(hairGesture)
        let extrasGesture = UITapGestureRecognizer(target: self, action: #selector(setExtrasCategory))
        extrasButton.addGestureRecognizer(extrasGesture)
        
        let buttonBackground = #imageLiteral(resourceName: "DiamondButton").resizableImage(withCapInsets: UIEdgeInsets(top: 18, left: 15, bottom: 18, right: 15))
        randomizeButton.setBackgroundImage(buttonBackground, for: .normal)
        
        let randomizeGesture = UITapGestureRecognizer(target: self, action: #selector(randomizeButtonTapped))
        randomizeButton.addGestureRecognizer(randomizeGesture)
        
        if self.view.frame.size.height <= 568 {
            contentHeight.constant = 120
            categoryHeight.constant = 85
        }
    }
    
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.windowBackgroundColor
    }
    
    func populateText() {
        randomizeButton.setTitle(L10n.randomize, for: .normal)
        speechbubbleView.text = L10n.Intro.avatarSetupSpeechbubble
        bodyLabel.text = L10n.Avatar.body
        skinLabel.text = L10n.Avatar.skin
        hairLabel.text = L10n.Avatar.hair
        extrasLabel.text = L10n.Avatar.extras
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentCategory = .body
    }
    
    @objc
    func setBodyCategory() {
        currentCategory = .body
    }
    
    @objc
    func setSkinCategory() {
        currentCategory = .skin
    }
    
    @objc
    func setHairCategory() {
        currentCategory = .hair
    }
    
    @objc
    func setExtrasCategory() {
        currentCategory = .extras
    }
    
    @objc
    func randomizeButtonTapped() {
        guard let user = self.user else {
            return
        }
        var updateData = [String: String]()
        updateData["preferences.size"] = chooseRandomKey(SetupCustomizationRepository.getCustomizations(category: .body, subcategory: .size, user: user), weighFirstOption: false)
        updateData["preferences.shirt"] = chooseRandomKey(SetupCustomizationRepository.getCustomizations(category: .body, subcategory: .shirt, user: user), weighFirstOption: false)
        updateData["preferences.skin"] = chooseRandomKey(SetupCustomizationRepository.getCustomizations(category: .skin, subcategory: .color, user: user), weighFirstOption: false)
        updateData["preferences.hair.color"] = chooseRandomKey(SetupCustomizationRepository.getCustomizations(category: .hair, subcategory: .color, user: user), weighFirstOption: false)
        updateData["preferences.hair.base"] = chooseRandomKey(SetupCustomizationRepository.getCustomizations(category: .hair, subcategory: .ponytail, user: user), weighFirstOption: false)
        updateData["preferences.hair.bangs"] = chooseRandomKey(SetupCustomizationRepository.getCustomizations(category: .hair, subcategory: .bangs, user: user), weighFirstOption: false)
        updateData["preferences.hair.flower"] = chooseRandomKey(SetupCustomizationRepository.getCustomizations(category: .extras, subcategory: .flower, user: user), weighFirstOption: true)
        updateData["preferences.chair"] = chooseRandomKey(SetupCustomizationRepository.getCustomizations(category: .extras, subcategory: .wheelchair, user: user), weighFirstOption: true)
        
        userRepository.updateUser(updateData).observeCompleted {}
    }
    
    func chooseRandomKey(_ items: [SetupCustomization], weighFirstOption: Bool) -> String {
        if items.isEmpty {
            return ""
        }
        if weighFirstOption {
            if Int(arc4random_uniform(10)) > 3 {
                return items[0].key
            }
        }
        return items[Int(arc4random_uniform(UInt32(items.count)))].key
    }

    private func setSubCategories(_ subcategories: [AvatarCustomizationSubcategory]) {
        subCategoryContainer.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        if subcategories.isEmpty {
            return
        }
        
        for subcategory in subcategories {
            let button = UIButton()
            button.setTitleColor(.white, for: .normal)
            button.setTitle(subcategory.text.uppercased(), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.alpha = 0.5
            button.addTarget(self, action: #selector(subcategoryTapped(_:)), for: .touchUpInside)
            subCategoryContainer.addArrangedSubview(button)
        }
        
        currentSubcategory = subcategories[0]
        
        if let activeIndex = getSubcategoriesForCurrentCategory().firstIndex(of: currentSubcategory), let button = subCategoryContainer.arrangedSubviews[activeIndex] as? UIButton {
            self.view.layoutIfNeeded()
            updateSubcategoryIndicator(button)
        }
    }

    private func updateCategoryButtons() {
        let selectedFrame = getActiveCategoryButton().frame
        let caretOffset = selectedFrame.origin.x + (selectedFrame.size.width / 2) - 10
        
        selectionCaretOffset.constant = caretOffset
        UIView.animate(withDuration: 0.2) {[weak self] in
            if self?.currentCategory == .body {
                self?.bodyImageView.alpha = 1.0
                self?.bodyLabel.alpha = 1.0
            } else {
                self?.bodyImageView.alpha = 0.5
                self?.bodyLabel.alpha = 0.5
            }
            if self?.currentCategory == .skin {
                self?.skinImageView.alpha = 1.0
                self?.skinLabel.alpha = 1.0
            } else {
                self?.skinImageView.alpha = 0.5
                self?.skinLabel.alpha = 0.5
            }
            if self?.currentCategory == .hair {
                self?.hairImageView.alpha = 1.0
                self?.hairLabel.alpha = 1.0
            } else {
                self?.hairImageView.alpha = 0.5
                self?.hairLabel.alpha = 0.5
            }
            if self?.currentCategory == .extras {
                self?.extrasImageView.alpha = 1.0
                self?.extrasLabel.alpha = 1.0
            } else {
                self?.extrasImageView.alpha = 0.5
                self?.extrasLabel.alpha = 0.5
            }
            
            self?.view.layoutIfNeeded()
        }
    }
    
    private func updateSubcategoryButtons() {
        let activeIndex = getSubcategoriesForCurrentCategory().firstIndex(of: currentSubcategory)
        UIView.animate(withDuration: 0.2) {[weak self] in
            guard let weakSelf = self else {
                return
            }
            for (index, view) in weakSelf.subCategoryContainer.arrangedSubviews.enumerated() {
                if let button = view as? UIButton {
                    if index == activeIndex {
                        button.alpha = 1.0
                        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
                    } else {
                        button.alpha = 0.5
                        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                    }
                }
            }
        }
    }
    
    private func getSubcategoriesForCurrentCategory() -> [AvatarCustomizationSubcategory] {
        switch currentCategory {
        case .body:
            return [.size, .shirt]
        case .skin:
            return [.color]
        case .hair:
            return [.color, .bangs, .ponytail]
        case .extras:
            return [.glasses, .flower, .wheelchair]
        }
    }
    
    @objc
    func subcategoryTapped(_ sender: UIButton!) {
        updateSubcategoryIndicator(sender)
        guard let activeIndex = subCategoryContainer.arrangedSubviews.firstIndex(of: sender) else {
            return
        }
        currentSubcategory = getSubcategoriesForCurrentCategory()[activeIndex]
    }
    
    private func updateContent() {
        contentContainer.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        if let user = self.user {
            content = SetupCustomizationRepository.getCustomizations(category: currentCategory, subcategory: currentSubcategory, user: user)
            for item in content {
                let view = SetupCustomizationItemView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                view.setItem(item)
                view.isActive = isCustomizationActive(item)
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(setupCustomizationTapped(_:)))
                view.addGestureRecognizer(tapGestureRecognizer)
                contentContainer.addArrangedSubview(view)
            }
            contentCenterConstraint.isActive = content.count <= 5
        }
    }
    
    @objc
    func setupCustomizationTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view as? SetupCustomizationItemView else {
            return
        }
        guard let activeIndex = contentContainer.arrangedSubviews.firstIndex(of: view) else {
            return
        }
        
        if let oldSelectedView = getSelectedView() {
            oldSelectedView.isActive = false
        }
        view.isActive = true
        
        let newCustomization = content[activeIndex]
        if newCustomization.path == "glasses" {
            var key: String?
            if newCustomization.key.isEmpty {
                key = user?.items?.gear?.equipped?.eyewear
            } else {
                key = newCustomization.key
            }
            inventoryRepository.equip(type: "equipped", key: key ?? "").observeCompleted {}
        } else {
            userRepository.updateUser(key: "preferences."+newCustomization.path, value: newCustomization.key).observeCompleted {}
        }
    }
    
    private func getSelectedView() -> SetupCustomizationItemView? {
        for view in contentContainer.arrangedSubviews {
            if let itemView = view as? SetupCustomizationItemView, itemView.isActive {
                return itemView
            }
        }
        return nil
    }
    
    private func updateActiveCustomizations() {
        for (index, item) in content.enumerated() {
            if let contentView = contentContainer.arrangedSubviews[index] as? SetupCustomizationItemView {
                contentView.isActive = isCustomizationActive(item)
            }
        }
        
        if let user = self.user {
            avatarView.avatar = AvatarViewModel(avatar: user)
        }
    }
    
    private func updateSubcategoryIndicator(_ button: UIButton) {
        if let title = button.title(for: .normal), let font = button.titleLabel?.font {
            let width = title.widthWithConstrainedHeight(CGFloat.greatestFiniteMagnitude, font: font)+30
            let middle = button.frame.origin.x+16+button.frame.size.width/2
            subcategoryIndicatorPosition.constant = middle - width/2
            subcategoryIndicatorWidth.constant = width
        }
        UIView.animate(withDuration: 0.2) {[weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    private func getActiveCategoryButton() -> UIView {
        switch currentCategory {
        case .body:
            return bodyButton
        case .skin:
            return skinButton
        case .hair:
            return hairButton
        case .extras:
            return extrasButton
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func isCustomizationActive(_ customization: SetupCustomization) -> Bool {
        if user?.isValid == false || user?.preferences?.isValid == false {
            return false
        }
        if let user = self.user {
            switch customization.subcategory {
            case .size:
                return customization.key == user.preferences?.size ?? ""
            case .shirt:
                return customization.key == user.preferences?.shirt ?? ""
            case .color:
                if customization.category == .skin {
                    return customization.key == user.preferences?.skin ?? ""
                } else {
                    return customization.key == user.preferences?.hair?.color ?? ""
                }
            case .ponytail:
                return customization.key == String(user.preferences?.hair?.base ?? 0)
            case .bangs:
                return customization.key == String(user.preferences?.hair?.bangs ?? 0)
            case .flower:
                return customization.key == String(user.preferences?.hair?.flower ?? 0)
            case .glasses:
                return customization.key == user.items?.gear?.equipped?.eyewear ?? ""
            case .wheelchair:
                return "chair_"+customization.key == user.preferences?.chair ?? "" || customization.key == user.preferences?.chair ?? "" || (customization.key == "none" && user.preferences?.chair == nil)
            default:
                return false
            }
        }
        return false
    }
    
    func startTyping() {
        speechbubbleView.animateTextView()
    }
}
