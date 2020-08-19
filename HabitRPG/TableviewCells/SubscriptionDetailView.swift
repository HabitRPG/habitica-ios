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
    @IBOutlet weak private var paymentMethodIconView: UIImageView!
    @IBOutlet weak private var monthsSubscribedPill: PillView!
    @IBOutlet weak private var gemCapPill: PillView!
    @IBOutlet weak private var hourGlassCountPill: PillView!
    @IBOutlet weak private var cancelDescriptionLabel: UILabel!
    @IBOutlet weak private var cancelDescriptionButton: UIButton!
    @IBOutlet weak var subscriptionBackground: UIView!
    @IBOutlet weak var paymentBackground: UIView!
    @IBOutlet weak var bonusBackground: UIView!
    @IBOutlet weak var cancelBackground: UIView!
    @IBOutlet weak var cancelTitleLabel: UILabel!
    @IBOutlet weak var subscriptionTitleLabel: UILabel!
    @IBOutlet weak var paymentTitleLabel: UILabel!
    @IBOutlet weak var bonusTitleLabel: UILabel!
    @IBOutlet weak var bonus1Label: UILabel!
    @IBOutlet weak var bonus2Label: UILabel!
    @IBOutlet weak var bonus3Label: UILabel!
    
    var cancelSubscriptionAction: (() -> Void)?

    // swiftlint:disable:next cyclomatic_complexity
    public func setPlan(_ plan: SubscriptionPlanProtocol) {
        if plan.isActive {
            if plan.isGifted {
                statusPill.text = L10n.notRecurring
                statusPill.pillColor = .yellow10
            } else if plan.isGroupPlanSub {
                statusPill.text = L10n.groupPlan
                statusPill.pillColor = .purple300
            } else if plan.dateTerminated != nil {
                statusPill.text = L10n.cancelled
                statusPill.pillColor = .red10
            } else {
                statusPill.text = L10n.active
                statusPill.pillColor = .green50
            }
        } else {
            statusPill.text = L10n.inactive
            statusPill.pillColor = .red10
        }
        var duration: String?
        switch plan.planId {
        case "basic_earned":
                duration = L10n.durationMonth
        case "basic":
                duration = L10n.durationMonth
        case "basic_3mo":
            duration = L10n.duration3month
        case "basic_6mo":
            duration = L10n.duration6month
        case "google_6mo":
            duration = L10n.duration6month
        case "basic_12mo":
                duration = L10n.duration12month
        default:
            break
        }
        if let duration = duration {
            typeLabel.text = L10n.subscriptionDuration(duration)
        } else if plan.isGroupPlanSub {
            typeLabel.text = L10n.memberGroupPlan
        } else if let terminated = plan.dateTerminated {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            typeLabel.text = L10n.endingOn(formatter.string(from: terminated))
        }
        switch plan.paymentMethod {
        case "Amazon Payments":
            paymentMethodIconView.image = Asset.paymentAmazon.image
        case "Apple":
            paymentMethodIconView.image = Asset.paymentApple.image
        case "Google":
            paymentMethodIconView.image = Asset.paymentGoogle.image
        case "PayPal":
            paymentMethodIconView.image = Asset.paymentPaypal.image
        case "Stripe":
            paymentMethodIconView.image = Asset.paymentStripe.image
        default:
            if plan.isGifted {
                paymentMethodIconView.image = Asset.paymentGift.image
            } else {
                paymentMethodIconView.image = nil
            }
        }

        // swiftlint:disable:next empty_count
        if plan.consecutive?.count == 0 {
            monthsSubscribedPill.text = L10n.oneMonth
        } else {
            monthsSubscribedPill.text = L10n.xMonths(plan.consecutive?.count ?? 0)
        }

        gemCapPill.text = String(plan.gemCapTotal)
        hourGlassCountPill.text = String(plan.consecutive?.hourglasses ?? 0)

        setCancelDescription(plan)
        
        applyTheme()
    }
    
    private func setCancelDescription(_ plan: SubscriptionPlanProtocol) {
        cancelTitleLabel.text = L10n.cancelSubscription
        cancelDescriptionButton.isHidden = false
        if plan.paymentMethod == "Apple" {
            cancelDescriptionLabel.text = L10n.unsubscribeItunes
            cancelDescriptionButton.setTitle(L10n.openItunes, for: .normal)
        } else if plan.paymentMethod != nil {
            cancelDescriptionLabel.text = L10n.unsubscribeWebsite
            cancelDescriptionButton.setTitle(L10n.openWebsite, for: .normal)
        } else if plan.isGroupPlanSub {
            cancelDescriptionLabel.text = L10n.cancelSubscriptionGroupPlan
            cancelDescriptionButton.isHidden = true
        } else if plan.dateTerminated != nil {
            cancelDescriptionButton.setTitle(L10n.renewSubscription, for: .normal)
            if plan.isGifted {
                cancelDescriptionLabel.text = L10n.renewSubscriptionGiftedDescription
                cancelTitleLabel.text = L10n.subscribe
            } else {
                cancelDescriptionLabel.text = L10n.renewSubscriptionDescription
                cancelTitleLabel.text = L10n.resubscribe
            }
        }
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
        bonusBackground.backgroundColor = theme.windowBackgroundColor
        bonusTitleLabel.textColor = theme.primaryTextColor
        bonus1Label.textColor = theme.secondaryTextColor
        monthsSubscribedPill.pillColor = theme.contentBackgroundColor
        gemCapPill.pillColor = theme.contentBackgroundColor
        hourGlassCountPill.pillColor = theme.contentBackgroundColor
        bonus2Label.textColor = theme.secondaryTextColor
        bonus3Label.textColor = theme.secondaryTextColor
        cancelBackground.backgroundColor = theme.windowBackgroundColor
    }
}
