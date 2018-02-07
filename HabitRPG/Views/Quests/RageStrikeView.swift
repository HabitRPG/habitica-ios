//
//  RageStrikeView.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class RageStrikeView: UIView {
    
    let backgroundView = UIImageView()
    let borderView = UIImageView(image: #imageLiteral(resourceName: "rage_strike_pending"))
    
    var isActive = false {
        didSet {
            if isActive {
                borderView.image = #imageLiteral(resourceName: "rage_strike_active")
                HRPGManager.shared().setImage("rage_strike_\(locationIdentifier)", withFormat: "png", on: backgroundView)
            } else {
                borderView.image = #imageLiteral(resourceName: "rage_strike_pending")
            }
        }
    }
    
    var locationIdentifier: String = ""
    
    var bossName = ""
    
    init() {
        super.init(frame: CGRect.zero)
        isUserInteractionEnabled = true
        
        backgroundView.contentMode = .center
        let mask = CALayer()
        mask.contents = #imageLiteral(resourceName: "rage_strike_pending").cgImage
        mask.frame = CGRect(x: 0, y: 0, width: 84, height: 84)
        backgroundView.layer.mask = mask
        backgroundView.layer.masksToBounds = true
        
        borderView.contentMode = .center
        
        addSubview(backgroundView)
        addSubview(borderView)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = CGRect(x: 0, y: 0, width: 84, height: 84)
        backgroundView.frame = frame
        borderView.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 84, height: 84)
    }
    
    private func getNPCName() -> String {
        switch locationIdentifier {
        case "market":
            return "Alex"
        case "tavern":
            return "Daniel"
        case "questShop":
            return "Ian"
        case "seasonalShop":
            return "Leslie"
        case "stable":
            return "Matt"
        default:
            return ""
        }
    }
    
    private func getLocationName() -> String {
        switch locationIdentifier {
        case "market":
            return NSLocalizedString("Market", comment: "")
        case "tavern":
            return NSLocalizedString("Tavern", comment: "")
        case "questShop":
            return NSLocalizedString("Quest Shop", comment: "")
        case "seasonalShop":
            return NSLocalizedString("Seasonal Shop", comment: "")
        case "stable":
            return NSLocalizedString("Stable", comment: "")
        default:
            return ""
        }
    }
    
    private func getLongNPCName() -> String {
        switch locationIdentifier {
        case "market":
            return NSLocalizedString("Alex the Merchant", comment: "")
        case "tavern":
            return NSLocalizedString("Daniel the inn keeper", comment: "")
        case "questShop":
            return NSLocalizedString("Ian the Quest Guide", comment: "")
        case "seasonalShop":
            return NSLocalizedString("Seasonal Sorceress", comment: "")
        case "stable":
            return NSLocalizedString("Matt the beast master", comment: "")
        default:
            return ""
        }
    }
    
    @objc
    func viewTapped() {
        if isActive {
            let npcName = getNPCName()
            let locationName = getLocationName()
            let npcLongName = getLongNPCName()
            let string = NSLocalizedString("\(npcName) is Heartbroken!\nOur beloved \(npcLongName) was devastated when \(bossName) shattered the \(locationName). Quickly, tackle your tasks to defeat the monster and help rebuild!", comment: "")
            let attributedString = NSMutableAttributedString(string: string)
            let firstLineRange = NSRange(location: 0, length: string.components(separatedBy: "\n")[0].count)
            attributedString.addAttribute(.font, value: CustomFontMetrics.scaledSystemFont(ofSize: 17), range: firstLineRange)
            attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: firstLineRange)
            attributedString.addAttribute(.font, value: CustomFontMetrics.scaledSystemFont(ofSize: 15), range: NSRange.init(location: firstLineRange.length, length: string.count - firstLineRange.length))
            let alertController = HabiticaAlertController.alert(title: NSLocalizedString("The \(locationName) was Attacked!", comment: ""), attributedMessage: attributedString)
            alertController.titleBackgroundColor = UIColor.orange50()
            alertController.addCloseAction()
            let npcImageView = UIImageView()
            HRPGManager.shared().setImage("npc_alex", withFormat: "png", on: npcImageView)
            alertController.show()
            alertController.containerView.insertArrangedSubview(npcImageView, at: 0)
            alertController.titleLabel.textColor = .white
        } else {
            let string = NSLocalizedString("The DysHeartener attacks!\nThe World Boss will lash out and attack one of our friendly shopkeepers once its rage bar fills. Keep up with your Dailies to try and prevent it from happening!", comment: "")
            let attributedString = NSMutableAttributedString(string: string)
            let firstLineRange = NSRange(location: 0, length: string.components(separatedBy: "\n")[0].count)
            attributedString.addAttribute(.font, value: CustomFontMetrics.scaledSystemFont(ofSize: 17), range: firstLineRange)
            attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: firstLineRange)
            attributedString.addAttribute(.font, value: CustomFontMetrics.scaledSystemFont(ofSize: 15), range: NSRange.init(location: firstLineRange.length, length: string.count - firstLineRange.length))
            let alertController = HabiticaAlertController.alert(title: NSLocalizedString("Pending Strike", comment: ""), attributedMessage: attributedString)
            alertController.titleBackgroundColor = UIColor.orange50()
            alertController.addCloseAction()
            alertController.show()
            alertController.titleLabel.textColor = .white
        }
    }
}
