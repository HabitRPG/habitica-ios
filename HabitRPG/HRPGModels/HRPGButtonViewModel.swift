//
//  HRPGButtonViewModel.swift
//  Habitica
//
//  Created by Elliot Schrock on 11/27/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import ReactiveSwift

protocol HRPGButtonModelInputs: class {
    func hrpgButtonPressed()
}

protocol HRPGButtonAttributeProvider: class {
    var bgColorSignal: Signal<UIColor, Never> { get }
    var titleSignal: Signal<String, Never> { get }
    var enabledSignal: Signal<Bool, Never> { get }
    
    func triggerStyle()
}

class HRPGButtonViewModel {
    weak var button: UIButton? {
        didSet {
            observeValues()
            attributeProvider?.triggerStyle()
        }
    }
    
    public weak var attributeProvider: HRPGButtonAttributeProvider? {
        didSet {
            observeValues()
            attributeProvider?.triggerStyle()
        }
    }
    
    private func observeValues() {
        attributeProvider?.bgColorSignal.observeValues({ [weak self] (color) in
            self?.button?.backgroundColor = color
        })
        
        attributeProvider?.titleSignal.observeValues({ [weak self] (title) in
            self?.button?.setTitle(title, for: .normal)
        })
        
        attributeProvider?.enabledSignal.observeValues({ [weak self] (isEnabled) in
            self?.button?.isEnabled = isEnabled
        })
    }
}
