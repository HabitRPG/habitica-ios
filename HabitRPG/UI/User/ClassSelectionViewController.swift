//
//  ClassSelectionViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 26.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift
import PinLayout

class SelectionIconView: UIView {
    var selectedBorderColor: UIColor
    var selectedBackgroundColor: UIColor
    var selectionAction: (() -> Void)?
    
    private let imageView = UIImageView()
    
    init(image: UIImage, selectedBorderColor: UIColor, selectedBackgroundColor: UIColor) {
        self.selectedBorderColor = selectedBorderColor
        self.selectedBackgroundColor = selectedBackgroundColor
        super.init(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        addSubview(imageView)
        imageView.image = image
        layer.borderColor = UIColor.gray700.cgColor
        layer.borderWidth = 4
        backgroundColor = .gray500
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapped)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isSelected: Bool = false {
        didSet {
            UIView.animate(springDuration: 0.3) {
                if self.isSelected {
                    self.layer.borderColor = self.selectedBorderColor.cgColor
                    self.layer.borderWidth = 6
                    self.backgroundColor = self.selectedBackgroundColor
                } else {
                    self.layer.borderColor = UIColor.gray700.cgColor
                    self.layer.borderWidth = 4
                    self.backgroundColor = .gray500
                }
                let size: CGFloat = self.isSelected ? 85 : 64
                self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: size, height: size)
                self.imageView.pin.center().size(self.isSelected ? 55 : 40)
                self.imageView.alpha = isSelected ? 1 : 0.5
                self.cornerRadius = self.bounds.size.width / 2
            }
        }
    }
    
    @objc
    fileprivate func onTapped() {
        if let action = selectionAction {
            action()
        }
    }
}

class ClassSelectionViewController: UIViewController, Themeable {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var warriorOptionView: ClassSelectionOptionView!
    @IBOutlet weak var mageOptionView: ClassSelectionOptionView!
    @IBOutlet weak var healerOptionView: ClassSelectionOptionView!
    @IBOutlet weak var rogueOptionView: ClassSelectionOptionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    let warriorSelectionIcon = SelectionIconView(image: HabiticaIcons.imageOfWarriorLightBg,
                                                 selectedBorderColor: .maroon100,
                                                 selectedBackgroundColor: .red500)
    let mageSelectionIcon = SelectionIconView(image: HabiticaIcons.imageOfMageLightBg,
                                              selectedBorderColor: .blue100,
                                              selectedBackgroundColor: .blue500)
    let healerSelectionIcon = SelectionIconView(image: HabiticaIcons.imageOfHealerLightBg,
                                                selectedBorderColor: .yellow100,
                                                selectedBackgroundColor: .yellow500)
    let rogueSelectionIcon = SelectionIconView(image: HabiticaIcons.imageOfRogueLightBg,
                                               selectedBorderColor: .purple300,
                                               selectedBackgroundColor: .purple600)
    let classSelectionRowWidth: CGFloat = 313
    
    private let userRepository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    private var selectedClass: HabiticaClass?
    private var isSelecting = false
    
    private var showBottomView = false
    private var selectedView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = L10n.Titles.selectClass
        
        configure(view: warriorOptionView, class: .warrior)
        configure(view: mageOptionView, class: .mage)
        configure(view: healerOptionView, class: .healer)
        configure(view: rogueOptionView, class: .rogue)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.gray10]
        disposable.inner.add(userRepository.getUser()
            .take(first: 1)
            .filter({ user in !user.canChooseClassForFree })
            .flatMap(.latest) { _ in
                return self.userRepository.selectClass()
            }.start())
        
        ThemeService.shared.addThemeable(themable: self)
        
        view.addSubview(warriorSelectionIcon)
        view.addSubview(mageSelectionIcon)
        view.addSubview(healerSelectionIcon)
        view.addSubview(rogueSelectionIcon)
        
        warriorSelectionIcon.selectionAction = {[weak self] in
            self?.set(class: .warrior, initial: false)
        }
        mageSelectionIcon.selectionAction = {[weak self] in
            self?.set(class: .mage, initial: false)
        }
        healerSelectionIcon.selectionAction = {[weak self] in
            self?.set(class: .healer, initial: false)
        }
        rogueSelectionIcon.selectionAction = {[weak self] in
            self?.set(class: .rogue, initial: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.view.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showView()
    }
    
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.contentBackgroundColor
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomView.layer.cornerRadius = UIConstants.largeCornerRadius
        if #available(iOS 26.0, *) {
            selectionButton.cornerConfiguration = .capsule()
            selectionButton.configuration = .prominentGlass()
        } else {
            selectionButton.cornerRadius = UIConstants.mediumCornerRadius
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layout()
    }
    
    private func showView() {
        UIView.animate(withDuration: 0.4, animations: {
            self.navigationController?.view.alpha = 1
        }, completion: { (done) in
            if !done {
                return
            }
            self.set(class: .warrior, initial: true)
            UIView.animate(withDuration: 0.6) {
                self.showBottomView = true
                self.bottomView.pin.top(61%)
                self.healerSelectionIcon.pin.vCenter(to: self.bottomView.edge.top)
                self.mageSelectionIcon.pin.vCenter(to: self.bottomView.edge.top)
                self.rogueSelectionIcon.pin.vCenter(to: self.bottomView.edge.top)
                self.warriorSelectionIcon.pin.vCenter(to: self.bottomView.edge.top)
            }
            UIView.animate(withDuration: 0.2, delay: 0.5, options: [], animations: {
                self.titleView.alpha = 1
                self.descriptionView.alpha = 1
                self.selectionButton.alpha = 1
            }, completion: nil)
        })
    }
    
    private func layout() {
        if showBottomView {
            bottomView.pin.horizontally().height(39%).top(61%)
        } else {
            bottomView.pin.horizontally().height(39%).top(100%)
        }
        titleView.pin.top(60).left(16).right(16).height(28)
        selectionButton.pin.bottom(36).left(16).right(16).height(60)
        descriptionView.pin.above(of: selectionButton).marginBottom(12).below(of: titleView).horizontally(40)
        
        let itemWidth = (view.bounds.size.width - 50) / 2
        let itemHeight = ((view.bounds.size.height * 0.535) - (view.pin.safeArea.top + 50)) / 2
        if let selectedView = self.selectedView {
            selectedView.pin.vCenter().hCenter()
            loadingIndicator.pin.below(of: selectedView).marginTop(12).hCenter()
        } else {
            healerOptionView.pin.left(25).top(view.pin.safeArea.top).width(itemWidth).height(itemHeight)
            mageOptionView.pin.right(of: healerOptionView).top(view.pin.safeArea.top).width(itemWidth).height(itemHeight)
            rogueOptionView.pin.below(of: healerOptionView).left(25).width(itemWidth).height(itemHeight)
            warriorOptionView.pin.below(of: mageOptionView).right(of: rogueOptionView).width(itemWidth).height(itemHeight)
            
            healerSelectionIcon.pin.vCenter(to: bottomView.edge.top).left((view.bounds.width - classSelectionRowWidth) / 2).sizeToFit()
            mageSelectionIcon.pin.vCenter(to: bottomView.edge.top).right(of: healerSelectionIcon).marginLeft(12)
            rogueSelectionIcon.pin.vCenter(to: bottomView.edge.top).right(of: mageSelectionIcon).marginLeft(12)
            warriorSelectionIcon.pin.vCenter(to: bottomView.edge.top).right(of: rogueSelectionIcon).marginLeft(12)
        }
    }
    
    private func configure(view: ClassSelectionOptionView, class habiticaClass: HabiticaClass) {
        view.configure(habiticaClass: habiticaClass) {
            self.set(class: habiticaClass, initial: false)
        }
        disposable.inner.add(userRepository.getUserStyleWithOutfitFor(class: habiticaClass).on(value: { userStyle in
            view.userStyle = userStyle
        }).start())
    }
    
    private func set(class habiticaClass: HabiticaClass, initial: Bool) {
        self.selectedClass = habiticaClass
        switch habiticaClass {
        case .warrior:
            configure(className: L10n.Classes.warrior, description: L10n.Classes.warriorDescription, textColor: .white, upperBackgroundColor: .red500, backgroundColor: .maroon100, buttonColor: .blue1)
        case .mage:
            configure(className: L10n.Classes.mage, description: L10n.Classes.mageDescription, textColor: .blue1, upperBackgroundColor: .blue500, backgroundColor: UIColor.blue100, buttonColor: .blue1)
        case .healer:
            configure(className: L10n.Classes.healer, description: L10n.Classes.healerDescription, textColor: .yellow1, upperBackgroundColor: .yellow500, backgroundColor: UIColor.yellow100, buttonColor: .yellow1)
        case .rogue:
            configure(className: L10n.Classes.rogue, description: L10n.Classes.rogueDescription, textColor: .white, upperBackgroundColor: .purple600, backgroundColor: UIColor.purple300, buttonColor: UIColor.purple50)
        }
        warriorOptionView.isSelected = habiticaClass == .warrior
        mageOptionView.isSelected = habiticaClass == .mage
        healerOptionView.isSelected = habiticaClass == .healer
        rogueOptionView.isSelected = habiticaClass == .rogue
        
        warriorSelectionIcon.isSelected = habiticaClass == .warrior
        rogueSelectionIcon.isSelected = habiticaClass == .rogue
        mageSelectionIcon.isSelected = habiticaClass == .mage
        healerSelectionIcon.isSelected = habiticaClass == .healer
        
        UIView.animate(springDuration: 0.3) {
            self.healerSelectionIcon.pin.vCenter(to: self.bottomView.edge.top).left((view.bounds.width - classSelectionRowWidth) / 2)
            self.mageSelectionIcon.pin.vCenter(to: self.bottomView.edge.top).right(of: self.healerSelectionIcon).marginLeft(12)
            self.rogueSelectionIcon.pin.vCenter(to: self.bottomView.edge.top).right(of: self.mageSelectionIcon).marginLeft(12)
            self.warriorSelectionIcon.pin.vCenter(to: self.bottomView.edge.top).right(of: self.rogueSelectionIcon).marginLeft(12)
        }
    }
    
    private func configure(className: String, description: String, textColor: UIColor, upperBackgroundColor: UIColor, backgroundColor: UIColor, buttonColor: UIColor) {
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.titleView.text = L10n.Classes.classHeader(className)
            self?.titleView.textColor = textColor
            self?.descriptionView.text = description
            self?.descriptionView.textColor = textColor
            self?.bottomView.backgroundColor = backgroundColor
            self?.selectionButton.tintColor = .white
            self?.selectionButton.setTitleColor(buttonColor, for: .normal)
            self?.selectionButton.setTitle(L10n.Classes.becomeAClass(className), for: .normal)
            self?.view.backgroundColor = upperBackgroundColor
        }
    }
    
    @IBAction func selectClass(_ sender: Any) {
        if isSelecting {
            return
        }
        isSelecting = true
        if let selectedClass = self.selectedClass {
            switch selectedClass {
            case .warrior:
                selectedView = warriorOptionView
            case .mage:
                selectedView = mageOptionView
            case .healer:
                selectedView = healerOptionView
            case .rogue:
                selectedView = rogueOptionView
            }
            showLoadingSelection()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.userRepository.selectClass(selectedClass)
                    .observeValues { _ in
                 self.dismiss(animated: true, completion: nil)
                 }
            }
            
        }
    }
    
    private func showLoadingSelection() {
        loadingIndicator.startAnimating()
        if let selectedView = selectedView {
            showBottomView = false
            UIView.animate(springDuration: 0.3) {[weak self] in
                self?.navigationController?.navigationBar.alpha = 0
                self?.hideView(self?.warriorOptionView)
                self?.hideView(self?.mageOptionView)
                self?.hideView(self?.healerOptionView)
                self?.hideView(self?.rogueOptionView)
            }
            UIView.animate(springDuration: 0.6, animations: {[weak self] in
                selectedView.pin.vCenter().hCenter()
                self?.bottomView.pin.top(100%)
                self?.healerSelectionIcon.alpha = 0
                self?.mageSelectionIcon.alpha = 0
                self?.rogueSelectionIcon.alpha = 0
                self?.warriorSelectionIcon.alpha = 0
            }, completion: {[weak self] (_) in
                self?.loadingIndicator.pin.below(of: selectedView).marginTop(12).hCenter()
                UIView.animate(withDuration: 0.3, animations: {[weak self] in
                    self?.loadingIndicator.alpha = 1
                })
            })
        }
    }
    
    private func hideView(_ view: UIView?) {
        if selectedView != view {
            view?.alpha = 0
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if !isSelecting {
            isSelecting = true
            self.userRepository.disableClassSystem().observeValues {[weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        UserManager.shared.classSelectionViewController = nil
        if !isPresenting {
            super.dismiss(animated: flag, completion: completion)
        } else if let presented = presentedViewController as? HabiticaAlertController {
            presented.onDismissAction = {[weak self] in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self?.dismiss(animated: true)
                })
            }
        }
    }
}
