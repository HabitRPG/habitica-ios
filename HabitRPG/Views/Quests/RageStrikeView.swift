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
                backgroundView.setImagewith(name: "rage_strike_\(locationIdentifier)")
            } else {
                borderView.image = #imageLiteral(resourceName: "rage_strike_pending")
            }
        }
    }
    
    var locationIdentifier: String = ""
    
    var questIdentifier = ""
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
            return L10n.Locations.market
        case "tavern":
            return L10n.Locations.tavern
        case "questShop":
            return L10n.Locations.questShop
        case "seasonalShop":
            return L10n.Locations.seasonalShop
        case "stable":
            return L10n.Locations.stable
        default:
            return ""
        }
    }
    
    private func getLongNPCName() -> String {
        switch locationIdentifier {
        case "market":
            return L10n.NPCs.alex
        case "tavern":
            return L10n.NPCs.daniel
        case "questShop":
            return L10n.NPCs.ian
        case "seasonalShop":
            return L10n.NPCs.seasonalSorceress
        case "stable":
            return L10n.NPCs.matt
        default:
            return ""
        }
    }
    
    @objc
    func viewTapped() {
        if isActive {
            let locationName = getLocationName()
            let string = L10n.WorldBoss.rageStrikeDamaged(getNPCName(), getLongNPCName(), bossName, getLocationName())
            let attributedString = NSMutableAttributedString(string: string)
            let firstLineRange = NSRange(location: 0, length: string.components(separatedBy: "\n")[0].count)
            attributedString.addAttribute(.font, value: CustomFontMetrics.scaledSystemFont(ofSize: 17), range: firstLineRange)
            attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: firstLineRange)
            attributedString.addAttribute(.font, value: CustomFontMetrics.scaledSystemFont(ofSize: 15), range: NSRange.init(location: firstLineRange.length, length: string.count - firstLineRange.length))
            let alertController = HabiticaAlertController.alert(title: L10n.WorldBoss.rageStrikeTitle(locationName))
            alertController.contentViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
            alertController.containerViewSpacing = 0
            alertController.titleBackgroundColor = UIColor.orange50()
            alertController.addCloseAction()
            guard let contentView = Bundle.main.loadNibNamed("RageStrikeActiveContentView", owner: self, options: nil)?.first as? UIView else {
                return
            }
            let npcBackgroundView = contentView.viewWithTag(1) as? UIImageView
            let npcSceneView = contentView.viewWithTag(2) as? UIImageView
            let label = contentView.viewWithTag(3) as? UITextView
            
            ImageManager.getImage(name: "\(locationIdentifier)_background_\(questIdentifier)") { (image, _) in
                npcBackgroundView?.image = image?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: UIImage.ResizingMode.tile)

            }
            npcSceneView?.setImagewith(name: "\(locationIdentifier)_scene_\(questIdentifier)")
            label?.attributedText = attributedString
            label?.textAlignment = .center
            alertController.contentView = contentView
            alertController.show()
            alertController.view.setNeedsLayout()
            alertController.titleLabel.textColor = .white
        } else {
            let string = L10n.WorldBoss.rageStrikeWarning
            let attributedString = NSMutableAttributedString(string: string)
            let firstLineRange = NSRange(location: 0, length: string.components(separatedBy: "\n")[0].count)
            attributedString.addAttribute(.font, value: CustomFontMetrics.scaledSystemFont(ofSize: 17), range: firstLineRange)
            attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: firstLineRange)
            attributedString.addAttribute(.font, value: CustomFontMetrics.scaledSystemFont(ofSize: 15), range: NSRange.init(location: firstLineRange.length, length: string.count - firstLineRange.length))
            let alertController = HabiticaAlertController.alert(title: L10n.WorldBoss.pendingStrike, attributedMessage: attributedString)
            alertController.titleBackgroundColor = UIColor.orange50()
            alertController.addCloseAction()
            alertController.show()
            alertController.titleLabel.textColor = .white
        }
    }
}
