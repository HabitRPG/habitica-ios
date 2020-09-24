//
//  PromotionInfoViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation

class PromotionInfoViewController: BaseUIViewController {
    
    private let configRepository = ConfigRepository()
    
    var promotion: HabiticaPromotion?
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var promoBanner: PromoBannerView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var promptButton: UIButton!
    @IBOutlet weak var instructionsTitleLabel: UILabel!
    @IBOutlet weak var instructionsDescriptionLabel: UILabel!
    @IBOutlet weak var limitationsTitleLabel: UILabel!
    @IBOutlet weak var limitationsDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        promotion = configRepository.activePromotion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainStackView.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 16, right: 20)
        mainStackView.isLayoutMarginsRelativeArrangement = true
        
        promotion?.configureInfoView(self)
        
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.shadowColor = .clear
            navigationController?.navigationBar.compactAppearance?.shadowColor = .clear
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if promotion == nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        navigationController?.navigationBar.shadowImage = UIImage()
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.backgroundColor = theme.contentBackgroundColor
        } else {
            navigationController?.navigationBar.backgroundColor = theme.contentBackgroundColor
        }
        instructionsTitleLabel.textColor = theme.secondaryTextColor
        limitationsTitleLabel.textColor = theme.secondaryTextColor
        instructionsDescriptionLabel.textColor = theme.ternaryTextColor
        limitationsDescriptionLabel.textColor = theme.ternaryTextColor
    }
    
    @IBAction func promptButtonTapped(_ sender: Any) {
        guard let promo = promotion else {
            return
        }
        if promo.promoType == .gemsAmount || promo.promoType == .gemsPrice {
            perform(segue: StoryboardSegue.Main.purchaseGemsSegue)
        } else if promo.promoType == .subscription {
            perform(segue: StoryboardSegue.Main.subscriptionSegue)
        }
    }
}
