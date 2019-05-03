//
//  ClassSelectionViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 26.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift
import PinLayout

class ClassSelectionViewController: UIViewController {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var warriorOptionView: ClassSelectionOptionView!
    @IBOutlet weak var mageOptionView: ClassSelectionOptionView!
    @IBOutlet weak var healerOptionView: ClassSelectionOptionView!
    @IBOutlet weak var rogueOptionView: ClassSelectionOptionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.view.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layout()
    }
    
    private func showView() {
        UIView.animate(withDuration: 0.4, animations: {
            self.navigationController?.view.alpha = 1
        }, completion: { (_) in
            self.set(class: .warrior)
            UIView.animate(withDuration: 0.6) {
                self.bottomView.pin.top(58%)
            }
            UIView.animate(withDuration: 0.2, delay: 0.5, options: [], animations: {
                self.titleView.alpha = 1
                self.descriptionView.alpha = 1
                self.selectionButton.alpha = 1
            }, completion: nil)
        })
    }
    
    private func layout() {
        let itemWidth = (view.bounds.size.width - 50) / 2
        let itemHeight = ((view.bounds.size.height * 0.575) - (view.pin.safeArea.top + 50)) / 2
        if let selectedView = self.selectedView {
            selectedView.pin.vCenter().hCenter()
            loadingIndicator.pin.below(of: selectedView).marginTop(12).hCenter()
        } else {
            healerOptionView.pin.left(25).top(view.pin.safeArea.top+10).width(itemWidth).height(itemHeight)
            mageOptionView.pin.right(of: healerOptionView).top(view.pin.safeArea.top+10).width(itemWidth).height(itemHeight)
            rogueOptionView.pin.below(of: healerOptionView).marginTop(6).left(25).width(itemWidth).height(itemHeight)
            warriorOptionView.pin.below(of: mageOptionView).marginTop(6).right(of: rogueOptionView).width(itemWidth).height(itemHeight)
        }
        
        if showBottomView {
            bottomView.pin.left().right().height(42.5%).top(57.5%)
        } else {
            bottomView.pin.left().right().height(42.5%).top(100%)
        }
        titleView.pin.top(20).left(16).right(16).height(28)
        selectionButton.pin.bottom(28).left(16).right(16).height(43)
        descriptionView.pin.above(of: selectionButton).marginBottom(12).below(of: titleView).left(16).right(16)
    }
    
    private func configure(view: ClassSelectionOptionView, class habiticaClass: HabiticaClass) {
        view.configure(habiticaClass: habiticaClass) {
            self.set(class: habiticaClass)
        }
        disposable.inner.add(userRepository.getUserStyleWithOutfitFor(class: habiticaClass).on(value: { userStyle in
            view.userStyle = userStyle
        }).start())
    }
    
    private func set(class habiticaClass: HabiticaClass) {
        self.selectedClass = habiticaClass
        switch habiticaClass {
        case .warrior:
            configure(className: L10n.Classes.warrior, description: L10n.Classes.warriorDescription, textColor: .white, backgroundColor: UIColor.red50(), buttonColor: UIColor(white: 0.1, alpha: 0.2))
        case .mage:
            configure(className: L10n.Classes.mage, description: L10n.Classes.mageDescription, textColor: .white, backgroundColor: UIColor.blue50(), buttonColor: UIColor(white: 0.1, alpha: 0.2))
        case .healer:
            configure(className: L10n.Classes.healer, description: L10n.Classes.healerDescription, textColor: UIColor.gray50(), backgroundColor: UIColor.yellow100(), buttonColor: UIColor.yellow10())
        case .rogue:
            configure(className: L10n.Classes.rogue, description: L10n.Classes.rogueDescription, textColor: .white, backgroundColor: UIColor.purple300(), buttonColor: UIColor.purple100())
        }
        warriorOptionView.isSelected = habiticaClass == .warrior
        mageOptionView.isSelected = habiticaClass == .mage
        healerOptionView.isSelected = habiticaClass == .healer
        rogueOptionView.isSelected = habiticaClass == .rogue
    }
    
    private func configure(className: String, description: String, textColor: UIColor, backgroundColor: UIColor, buttonColor: UIColor) {
        UIView.animate(withDuration: 0.3) {
            self.titleView.text = L10n.Classes.classHeader(className)
            self.titleView.textColor = textColor
            self.descriptionView.text = description
            self.descriptionView.textColor = textColor
            self.bottomView.backgroundColor = backgroundColor
            self.selectionButton.backgroundColor = buttonColor
            self.selectionButton.setTitle(L10n.Classes.becomeAClass(className), for: .normal)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.userRepository.selectClass(selectedClass)
                    .on(failed: { _ in
                        self.isSelecting = false
                    })
                    .observeCompleted {
                 self.dismiss(animated: true, completion: nil)
                 }
            }
            
        }
    }
    
    private func showLoadingSelection() {
        loadingIndicator.startAnimating()
        if let selectedView = self.selectedView {
            showBottomView = false
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.navigationBar.alpha = 0
                self.hideView(self.warriorOptionView)
                self.hideView(self.mageOptionView)
                self.hideView(self.healerOptionView)
                self.hideView(self.rogueOptionView)
            }
            UIView.animate(withDuration: 0.6, animations: {
                selectedView.pin.vCenter().hCenter()
                self.bottomView.pin.top(100%)
            }, completion: { (_) in
                self.loadingIndicator.pin.below(of: selectedView).marginTop(12).hCenter()
                UIView.animate(withDuration: 0.3, animations: {
                    self.loadingIndicator.alpha = 1
                })
            })
        }
    }
    
    private func hideView(_ view: UIView) {
        if selectedView != view {
            view.alpha = 0
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if !isSelecting {
            self.userRepository.disableClassSystem().observeCompleted {}
        }
        self.dismiss(animated: true, completion: nil)
    }
}
