//
//  BulkStatsAllocationViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 30.11.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift
import FirebaseAnalytics

class BulkStatsAllocationViewController: UIViewController, Themeable {
    private let disposable = ScopedDisposable(CompositeDisposable())
    private let userRepository = UserRepository()

    private var user: UserProtocol?
    private var pointsToAllocate: Int = 0
    
    var pointsAllocated: Int {
        get {
            var value = 0
            value += strengthSliderView.value
            value += intelligenceSliderView.value
            value += constitutionSliderView.value
            value += perceptionSliderView.value
            return value
        }
    }
    
    @IBOutlet weak var headerWrapper: UIView!
    @IBOutlet weak var allocatedCountLabel: UILabel!
    @IBOutlet weak var allocatedLabel: UILabel!
    @IBOutlet weak var strengthSliderView: StatsSliderView!
    @IBOutlet weak var intelligenceSliderView: StatsSliderView!
    @IBOutlet weak var constitutionSliderView: StatsSliderView!
    @IBOutlet weak var perceptionSliderView: StatsSliderView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var buttonSeparator: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        disposable.inner.add(userRepository.getUser().take(first: 1).on(value: {[weak self]user in
            self?.user = user
            self?.pointsToAllocate = user.stats?.points ?? 0
            self?.updateUI()
        }).start())
        
        ThemeService.shared.addThemeable(themable: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logEvent("open_bulk_stats", parameters: nil)
    }
    
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.contentBackgroundColor
        headerWrapper.backgroundColor = theme.windowBackgroundColor
        allocatedLabel.textColor = theme.secondaryTextColor
        cancelButton.tintColor = theme.tintColor
        buttonSeparator.backgroundColor = theme.separatorColor
        
        saveButton.layer.shadowColor = ThemeService.shared.theme.buttonShadowColor.cgColor
        saveButton.layer.shadowRadius = 2
        saveButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        saveButton.layer.shadowOpacity = 0.5
        saveButton.layer.masksToBounds = false
        
        updateUI()
    }
    
    private func updateUI() {
        strengthSliderView.maxValue = pointsToAllocate
        intelligenceSliderView.maxValue = pointsToAllocate
        constitutionSliderView.maxValue = pointsToAllocate
        perceptionSliderView.maxValue = pointsToAllocate
        
        if let stats = user?.stats {
            strengthSliderView.originalValue = stats.strength
            intelligenceSliderView.originalValue = stats.intelligence
            constitutionSliderView.originalValue = stats.constitution
            perceptionSliderView.originalValue = stats.perception
        }
        
        strengthSliderView.allocateAction = {[weak self] _ in
            self?.checkRedistribution(excludedSlider: self?.strengthSliderView)
            self?.updateAllocatedCountLabel()
        }
        intelligenceSliderView.allocateAction = {[weak self] _ in
            self?.checkRedistribution(excludedSlider: self?.intelligenceSliderView)
            self?.updateAllocatedCountLabel()
        }
        constitutionSliderView.allocateAction = {[weak self] _ in
            self?.checkRedistribution(excludedSlider: self?.constitutionSliderView)
            self?.updateAllocatedCountLabel()
        }
        perceptionSliderView.allocateAction = {[weak self] _ in
            self?.checkRedistribution(excludedSlider: self?.perceptionSliderView)
            self?.updateAllocatedCountLabel()
        }
        
        updateAllocatedCountLabel()
    }
    
    private func checkRedistribution(excludedSlider: StatsSliderView?) {
        let diff = pointsAllocated - pointsToAllocate
        if diff > 0 {
            var highestSlider: StatsSliderView?
            if excludedSlider != strengthSliderView {
                highestSlider = getSliderWithHigherValue(first: highestSlider, second: strengthSliderView)
            }
            if excludedSlider != intelligenceSliderView {
                highestSlider = getSliderWithHigherValue(first: highestSlider, second: intelligenceSliderView)
            }
            if excludedSlider != constitutionSliderView {
                highestSlider = getSliderWithHigherValue(first: highestSlider, second: constitutionSliderView)
            }
            if excludedSlider != perceptionSliderView {
                highestSlider = getSliderWithHigherValue(first: highestSlider, second: perceptionSliderView)
            }
            highestSlider?.value -= diff
        }
    }
    
    private func getSliderWithHigherValue(first: StatsSliderView?, second: StatsSliderView?) -> StatsSliderView? {
        guard let firstSlider = first else {
            return second
        }
        guard let secondSlider = second else {
            return first
        }
        if firstSlider.value > secondSlider.value {
            return firstSlider
        } else {
            return secondSlider
        }
    }
    
    private func updateAllocatedCountLabel() {
        allocatedCountLabel.text = "\(pointsAllocated)/\(pointsToAllocate)"
        if pointsAllocated > 0 {
            allocatedCountLabel.textColor = ThemeService.shared.theme.tintColor
            saveButton.backgroundColor = ThemeService.shared.theme.tintColor
            saveButton.setTitleColor(.white, for: .normal)
        } else {
            allocatedCountLabel.textColor = ThemeService.shared.theme.secondaryTextColor
            saveButton.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
            saveButton.setTitleColor(ThemeService.shared.theme.quadTextColor, for: .normal)
        }
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        userRepository.bulkAllocate(strength: strengthSliderView.value,
                                    intelligence: intelligenceSliderView.value,
                                    constitution: constitutionSliderView.value,
                                    perception: perceptionSliderView.value).observeCompleted {}
    }
}
