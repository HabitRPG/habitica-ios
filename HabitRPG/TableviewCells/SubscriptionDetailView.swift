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

    var cancelSubscriptionAction: (() -> Void)?

    public func setPlan(_ plan: SubscriptionPlanProtocol) {
        if plan.isActive {
            statusPill.text = L10n.active
            statusPill.pillColor = .green50()
        } else {
            statusPill.text = L10n.inactive
            statusPill.pillColor = .red10()
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
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if let action = self.cancelSubscriptionAction {
            action()
        }
    }
}
