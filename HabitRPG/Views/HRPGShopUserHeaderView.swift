//
//  HRPGShopUserHeaderView.swift
//  Habitica
//
//  Created by Elliot Schrock on 7/13/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift

class HRPGShopUserHeaderView: UIView {
    @IBOutlet weak var userClassImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var hourglassCountView: HRPGCurrencyCountView!
    @IBOutlet weak var gemCountView: HRPGCurrencyCountView!
    @IBOutlet weak var goldCountView: HRPGCurrencyCountView!
    
    private let userRepository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.set(user: user)
        }).start())
    }
    
    override func awakeFromNib() {
        hourglassCountView.currency = .hourglass
        gemCountView.currency = .gem
        goldCountView.currency = .gold
        backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        super.awakeFromNib()
    }

    func set(user: UserProtocol) {
        usernameLabel.text = user.profile?.name
        usernameLabel.textColor = user.contributor?.color
        
        if let shouldDisable = user.preferences?.disableClasses, !shouldDisable, let userClass = user.stats?.habitClass {
            userClassImageView.isHidden = false
            userClassImageView.image = UIImage(named: "icon_\(userClass)")
        } else {
            userClassImageView.isHidden = true
        }
        
        goldCountView.amount = Int(user.stats?.gold ?? 0)
        gemCountView.amount = user.gemCount
        if let hourglassCount = user.purchased?.subscriptionPlan?.consecutive?.hourglasses {
            hourglassCountView.amount = hourglassCount
        }
    }

}
