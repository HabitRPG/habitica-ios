//
//  SubscriptionDetailView.swift
//  Habitica
//
//  Created by Phillip Thelen on 10/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class SubscriptionDetailView: UITableViewCell {

    @IBOutlet weak private var statusPill: PillView!
    @IBOutlet weak private var typeLabel: UILabel!
    @IBOutlet weak private var paymentMethodLabel: UILabel!
    @IBOutlet weak private var monthsSubscribedPill: PillView!
    @IBOutlet weak private var gemCapPill: PillView!
    @IBOutlet weak private var hourGlassCountPill: PillView!
    @IBOutlet weak private var cancelDescriptionLabel: UILabel!
    @IBOutlet weak private var cancelDescriptionButton: UIButton!
    @IBOutlet weak var subscriptionBackground: UIView!
    @IBOutlet weak var paymentBackground: UIView!
    @IBOutlet weak var bonusBackground: UIView!
    @IBOutlet weak var cancelBackground: UIView!
    @IBOutlet weak var subscriptionTitleLabel: UILabel!
    @IBOutlet weak var paymentTitleLabel: UILabel!
    @IBOutlet weak var bonusTitleLabel: UILabel!
    @IBOutlet weak var bonus1Label: UILabel!
    @IBOutlet weak var bonus2Label: UILabel!
    @IBOutlet weak var bonus3Label: UILabel!
    
    var cancelSubscriptionAction: (() -> Void)?

    public func setPlan(_ plan: SubscriptionPlanProtocol) {
        if plan.isActive {
            statusPill.text = L10n.active
            statusPill.pillColor = .green50
        } else {
            statusPill.text = L10n.inactive
            statusPill.pillColor = .red10
        }
        typeLabel.text = plan.planId
        paymentMethodLabel.text = plan.paymentMethod

        // swiftlint:disable:next empty_count
        if plan.consecutive?.count == 0 {
            monthsSubscribedPill.text = L10n.oneMonth
        } else {
            monthsSubscribedPill.text = L10n.xMonths(plan.consecutive?.count ?? 0)
        }

        gemCapPill.text = String(plan.gemCapTotal)
        hourGlassCountPill.text = String(plan.consecutive?.hourglasses ?? 0)

        if plan.paymentMethod == "Apple" {
            cancelDescriptionLabel.text = L10n.unsubscribeItunes
            cancelDescriptionButton.setTitle(L10n.openItunes, for: .normal)
        } else {
            cancelDescriptionLabel.text = L10n.unsubscribeWebsite
            cancelDescriptionButton.setTitle(L10n.openWebsite, for: .normal)
        }
        applyTheme()
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if let action = self.cancelSubscriptionAction {
            action()
        }
    }
    
    func applyTheme() {
        let theme = ThemeService.shared.theme
        subscriptionBackground.backgroundColor = theme.windowBackgroundColor
        subscriptionTitleLabel.textColor = theme.primaryTextColor
        typeLabel.textColor = theme.secondaryTextColor
        paymentBackground.backgroundColor = theme.windowBackgroundColor
        paymentTitleLabel.textColor = theme.primaryTextColor
        paymentMethodLabel.textColor = theme.secondaryTextColor
        bonusBackground.backgroundColor = theme.windowBackgroundColor
        bonusTitleLabel.textColor = theme.primaryTextColor
        bonus1Label.textColor = theme.secondaryTextColor
        bonus2Label.textColor = theme.secondaryTextColor
        bonus3Label.textColor = theme.secondaryTextColor
        cancelBackground.backgroundColor = theme.windowBackgroundColor
    }
}
