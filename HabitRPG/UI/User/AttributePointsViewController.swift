//
//  AttributePointsViewController.swift
//  Habitica
//
//  Created by Phillip on 27.11.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import PopupDialog

class AttributePointsVieController: HRPGUIViewController {
    
    @IBOutlet weak var pointsToAllocateLabel: PaddedLabel!
    @IBOutlet weak var pointsToAllocateRightView: UIImageView!
    @IBOutlet weak var pointsToAllocateLeftView: UIImageView!
    @IBOutlet weak var statsViewWrapper: UIStackView!
    @IBOutlet weak var strengthStatsView: StatsView!
    @IBOutlet weak var intelligenceStatsView: StatsView!
    @IBOutlet weak var constitutionStatsView: StatsView!
    @IBOutlet weak var perceptionStatsView: StatsView!
    @IBOutlet weak var autoAllocationSwitch: UISwitch!
    
    @IBOutlet weak var distributionStackView: UIStackView!
    @IBOutlet weak var distributionBackground: UIView!
    @IBOutlet weak var distributeEvenlyView: UIView!
    @IBOutlet weak var distributeEvenlyHelpView: UIImageView!
    @IBOutlet weak var distributeEvenlyCheckmark: UIImageView!
    @IBOutlet weak var distributeClassView: UIView!
    @IBOutlet weak var distributeClassHelpView: UIImageView!
    @IBOutlet weak var distributeClassCheckmark: UIImageView!
    @IBOutlet weak var distributeTaskView: UIView!
    @IBOutlet weak var distributeTaskHelpView: UIImageView!
    @IBOutlet weak var distributeTaskCheckmark: UIImageView!
    
    var totalStrength: Int = 0 {
        didSet {
            strengthStatsView.totalValue = totalStrength
        }
    }
    var totalIntelligence: Int = 0 {
        didSet {
            intelligenceStatsView.totalValue = totalIntelligence
        }
    }
    var totalConstitution: Int = 0 {
        didSet {
            constitutionStatsView.totalValue = totalConstitution
        }
    }
    var totalPerception: Int = 0 {
        didSet {
            perceptionStatsView.totalValue = totalPerception
        }
    }
    
    let user = HRPGManager.shared().getUser()
    private var observer: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator?.hideHeader = true
        self.tutorialIdentifier = "stats"
    }
    
    override func getDefinitonForTutorial(_ tutorialIdentifier: String) -> [AnyHashable: Any]? {
        if tutorialIdentifier == "stats" {
            return ["text": NSLocalizedString("Tap the gray button to allocate lots of your stats at once, or tap the arrows to add them one point at a time.", comment: "")]
        }
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pointsToAllocateLeftView.image = HabiticaIcons.imageOfAttributeSparklesLeft
        pointsToAllocateRightView.image = HabiticaIcons.imageOfAttributeSparklesRight
        
        updateUser()
        updateStats()
        updateAutoAllocatonViews()
        
        strengthStatsView.allocateAction = { [weak self] in self?.allocate("str") }
        intelligenceStatsView.allocateAction = { [weak self] in self?.allocate("int") }
        constitutionStatsView.allocateAction = { [weak self] in self?.allocate("con") }
        perceptionStatsView.allocateAction = { [weak self] in self?.allocate("per") }
        
        distributeEvenlyHelpView.image = HabiticaIcons.imageOfInfoIcon()
        distributeClassHelpView.image = HabiticaIcons.imageOfInfoIcon()
        distributeTaskHelpView.image = HabiticaIcons.imageOfInfoIcon()
        distributeEvenlyCheckmark.image = HabiticaIcons.imageOfCheckmark(checkmarkColor: UIColor.purple400(), percentage: 1.0)
        distributeClassCheckmark.image = HabiticaIcons.imageOfCheckmark(checkmarkColor: UIColor.purple400(), percentage: 1.0)
        distributeTaskCheckmark.image = HabiticaIcons.imageOfCheckmark(checkmarkColor: UIColor.purple400(), percentage: 1.0)
        
        distributeEvenlyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(distributeEvenlyTapped)))
        distributeClassView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(distributeClassTapped)))
        distributeTaskView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(distributeTaskTapped)))
        
        distributeEvenlyHelpView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(distributeEvenlyHelpTapped)))
        distributeClassHelpView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(distributeClassHelpTapped)))
        distributeTaskHelpView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(distributeTaskHelpTapped)))

        pointsToAllocateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openBulkAssignView)))
        pointsToAllocateLabel.horizontalPadding = 12
        pointsToAllocateLabel.verticalPadding = 4
        pointsToAllocateLabel.layer.cornerRadius = pointsToAllocateLabel.frame.size.height/2
        
        observer = user?.observe(\.pointsToAllocate, changeHandler: {[weak self] (_, _) in
            self?.updateUser()
            self?.updateStats()
            self?.updateAutoAllocatonViews()
        })
    }
    
    private func allocate(_ attribute: String) {
        HRPGManager.shared().allocateAttributePoint(attribute, onSuccess: {[weak self] in
        }, onError: {[weak self] in
        })
    }
    
    private func updateUser() {
        guard let user = user else {
            return
        }
        let canAllocatePoints = user.pointsToAllocate != 0
        pointsToAllocateLeftView.isHidden = !canAllocatePoints
        pointsToAllocateRightView.isHidden = !canAllocatePoints
        if !canAllocatePoints {
            pointsToAllocateLabel.text = NSLocalizedString("0 Points to Allocate", comment: "")
            pointsToAllocateLabel.backgroundColor = UIColor.white
            pointsToAllocateLabel.textColor = UIColor.gray300()
        } else {
            pointsToAllocateLabel.backgroundColor = UIColor.gray100()
            pointsToAllocateLabel.textColor = UIColor.white
            if user.pointsToAllocate == 1 {
                pointsToAllocateLabel.text = NSLocalizedString("1 Point to Allocate", comment: "")
            } else {
                pointsToAllocateLabel.text = String(format: NSLocalizedString("%@ Points to Allocate", comment: ""), user.pointsToAllocate)
            }
        }
        strengthStatsView.canAllocatePoints = canAllocatePoints
        intelligenceStatsView.canAllocatePoints = canAllocatePoints
        constitutionStatsView.canAllocatePoints = canAllocatePoints
        perceptionStatsView.canAllocatePoints = canAllocatePoints
    }
    
    private func updateStats() {
        guard let user = user else {
            return
        }
        let levelStat = user.level.intValue / 2
        
        totalStrength = levelStat
        totalIntelligence = levelStat
        totalConstitution = levelStat
        totalPerception = levelStat
        
        strengthStatsView.levelValue = levelStat
        intelligenceStatsView.levelValue = levelStat
        constitutionStatsView.levelValue = levelStat
        perceptionStatsView.levelValue = levelStat
        
        totalStrength += user.buff?.strength?.intValue ?? 0
        totalIntelligence += user.buff?.intelligence?.intValue ?? 0
        totalConstitution += user.buff?.constitution?.intValue ?? 0
        totalPerception += user.buff?.perception?.intValue ?? 0
        strengthStatsView.buffValue = user.buff?.strength?.intValue ?? 0
        intelligenceStatsView.buffValue = user.buff?.intelligence?.intValue ?? 0
        constitutionStatsView.buffValue = user.buff?.constitution?.intValue ?? 0
        perceptionStatsView.buffValue = user.buff?.perception?.intValue ?? 0
        
        totalStrength += user.strength?.intValue ?? 0
        totalIntelligence += user.intelligence?.intValue ?? 0
        totalConstitution += user.constitution?.intValue ?? 0
        totalPerception += user.perception?.intValue ?? 0
        strengthStatsView.allocatedValue = user.strength?.intValue ?? 0
        intelligenceStatsView.allocatedValue = user.intelligence?.intValue ?? 0
        constitutionStatsView.allocatedValue = user.constitution?.intValue ?? 0
        perceptionStatsView.allocatedValue = user.perception?.intValue ?? 0
        
        DispatchQueue.global(qos: .background).async {[weak self] in
            self?.fetchGearStats(user: user)
        }
    }
    
    private func fetchGearStats(user: User) {
        let fetchRequest = NSFetchRequest<Gear>(entityName: "Gear")
        var keys = [String]()
        keys.append(user.equipped?.armor ?? "")
        keys.append(user.equipped?.back ?? "")
        keys.append(user.equipped?.body ?? "")
        keys.append(user.equipped?.eyewear ?? "")
        keys.append(user.equipped?.head ?? "")
        keys.append(user.equipped?.headAccessory ?? "")
        keys.append(user.equipped?.weapon ?? "")
        keys.append(user.equipped?.shield ?? "")
        fetchRequest.predicate = NSPredicate(format: "key in %@", keys)
        let result = try? HRPGManager.shared().getManagedObjectContext().fetch(fetchRequest)
        if let gear = result {
            DispatchQueue.main.async {[weak self] in
                self?.updateGearStats(gear)
            }
        }
    }
    
    private func updateGearStats(_ gear: [Gear]) {
        var strength = 0.0
        var intelligence = 0.0
        var constitution = 0.0
        var perception = 0.0
        
        for row in gear {
            strength += row.str.doubleValue
            intelligence += row.intelligence.doubleValue
            constitution += row.con.doubleValue
            perception += row.per.doubleValue
            
            var itemClass = row.klass
            let itemSpecialClass = row.specialClass
            let classBonus = 0.5
            let userClassMatchesGearClass = itemClass == user?.hclass
            let userClassMatchesGearSpecialClass = itemSpecialClass == user?.hclass
            
            if !userClassMatchesGearClass && !userClassMatchesGearSpecialClass {
                continue
            }
            
            if itemClass?.isEmpty ?? false || itemClass == "special" {
                itemClass = itemSpecialClass
            }
            
            switch itemClass {
            case "rogue"?:
                strength += row.str.doubleValue * classBonus
                perception += row.per.doubleValue * classBonus
            case "healer"?:
                constitution += row.con.doubleValue * classBonus
                intelligence += row.intelligence.doubleValue * classBonus
            case "warrior"?:
                strength += row.str.doubleValue * classBonus
                constitution += row.con.doubleValue * classBonus
            case "wizard"?:
                intelligence += row.intelligence.doubleValue * classBonus
                perception += row.per.doubleValue * classBonus
            default:
                break
            }
        }
        
        totalStrength += Int(strength)
        totalIntelligence += Int(intelligence)
        totalConstitution += Int(constitution)
        totalPerception += Int(perception)
        strengthStatsView.equipmentValue = Int(strength)
        intelligenceStatsView.equipmentValue = Int(intelligence)
        constitutionStatsView.equipmentValue = Int(constitution)
        perceptionStatsView.equipmentValue = Int(perception)
    }
    
    private func updateAutoAllocatonViews() {
        let useAutoAllocation = user?.preferences?.automaticAllocation?.boolValue ?? false
        autoAllocationSwitch.isOn = useAutoAllocation
        distributionStackView.isHidden = !useAutoAllocation
        distributionBackground.isHidden = !useAutoAllocation
        if useAutoAllocation, let allocationMode = user?.preferences?.allocationMode {
            switch allocationMode {
            case "flat":
                distributeEvenlyCheckmark.isHidden = false
                distributeClassCheckmark.isHidden = true
                distributeTaskCheckmark.isHidden = true
            case "classbased":
                distributeEvenlyCheckmark.isHidden = true
                distributeClassCheckmark.isHidden = false
                distributeTaskCheckmark.isHidden = true
            case "taskbased":
                distributeEvenlyCheckmark.isHidden = true
                distributeClassCheckmark.isHidden = true
                distributeTaskCheckmark.isHidden = false
            default:
                break
            }
        }
    }
    
    @IBAction func autoAllocationChanged(_ sender: UISwitch) {
        user?.preferences?.automaticAllocation = NSNumber(value: sender.isOn)
        updateAutoAllocatonViews()
        HRPGManager.shared().updateUser(["preferences.automaticAllocation": sender.isOn], onSuccess: {[weak self] in
            self?.updateAutoAllocatonViews()
        }, onError: {[weak self] in
            self?.updateAutoAllocatonViews()
        })
    }
    
    @objc
    func distributeEvenlyTapped() {
        setAllocationMode("flat")
    }
    
    @objc
    func distributeClassTapped() {
        setAllocationMode("classbased")
    }
    
    @objc
    func distributeTaskTapped() {
        setAllocationMode("taskbased")
    }
    
    @objc
    func distributeEvenlyHelpTapped() {
        showHelpView(NSLocalizedString("Assigns the same number of points to each attribute.", comment: ""))
    }
    
    @objc
    func distributeClassHelpTapped() {
        showHelpView(NSLocalizedString("Assigns more points to the attributes important to your Class.", comment: ""))
    }
    
    @objc
    func distributeTaskHelpTapped() {
        showHelpView(NSLocalizedString("Assigns points based on the Strength, Intelligence, Constitution, and Perception categories associated with the tasks you complete.", comment: ""))
    }
    
    func showHelpView(_ message: String) {
        let alert = HabiticaAlertController.alert(title: nil, message: message)
        alert.addOkAction()
        alert.show()
    }
    
    private func setAllocationMode(_ mode: String) {
        user?.preferences?.allocationMode = mode
        updateAutoAllocatonViews()
        HRPGManager.shared().updateUser(["preferences.allocationMode": mode], onSuccess: {[weak self] in
            self?.updateAutoAllocatonViews()
            }, onError: {[weak self] in
                self?.updateAutoAllocatonViews()
        })
    }
    
    @objc
    func openBulkAssignView() {
        let viewController = BulkStatsAllocationViewController(nibName: "BulkStatsAllocationView", bundle: Bundle.main)
        let popup = PopupDialog(viewController: viewController, gestureDismissal: false) {
        }
    
        self.present(popup, animated: true, completion: nil)
    }
}
