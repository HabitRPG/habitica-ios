//
//  SubscriptionDetailView.swift
//  Habitica
//
//  Created by Phillip Thelen on 10/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class SubscriptionDetailView: UITableViewCell {

    @IBOutlet weak private var statusPill: PillView!
    @IBOutlet weak private var typeLabel: UILabel!
    @IBOutlet weak private var paymentMethodLabel: UILabel!
    @IBOutlet weak private var monthsSubscribedPill: PillView!
    @IBOutlet weak private var gemCapPill: PillView!
    @IBOutlet weak private var hourGlassCountPill: PillView!
    @IBOutlet weak private var cancelDescriptionLabel: UILabel!
    @IBOutlet weak private var cancelDescriptionButton: UIButton!

    var cancelSubscriptionAction: (() -> Void)?

    public func setPlan(_ plan: SubscriptionPlan) {
        if plan.isActive() {
            statusPill.text = "Active".localized
            statusPill.pillColor = .green50()
        } else {
            statusPill.text = "Inactive".localized
            statusPill.pillColor = .red10()
        }
        typeLabel.text = plan.planId
        paymentMethodLabel.text = plan.paymentMethod

        if plan.count == 0 {
            monthsSubscribedPill.text = "1 Month".localized
        } else {
            monthsSubscribedPill.text = "\(plan.count) Months".localized
        }

        gemCapPill.text = String(plan.totalGemCap)
        hourGlassCountPill.text = plan.consecutiveTrinkets?.stringValue

        if plan.paymentMethod == "Apple" {
            cancelDescriptionLabel.text = "No longer want to subscribe? You can manage your subscription from iTunes.".localized
            cancelDescriptionButton.setTitle("Open iTunes".localized, for: .normal)
        } else {
            cancelDescriptionLabel.text = "No longer want to subscribe? Due to your payment method, you can only unsubscribe through the website.".localized
            cancelDescriptionButton.setTitle("Open Habitica Website".localized, for: .normal)
        }
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if let action = self.cancelSubscriptionAction {
            action()
        }
    }
}
