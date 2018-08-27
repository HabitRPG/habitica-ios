//
//  AttributePointsViewController.swift
//  Habitica
//
//  Created by Phillip on 27.11.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import PopupDialog
import Habitica_Models
import ReactiveSwift
import Result

class AttributePointsViewController: HRPGUIViewController, Themeable {
    
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
    
    var user: UserProtocol?
    private let userRepository = UserRepository()
    private let inventoryRepository = InventoryRepository()
    var interactor = CalculateUserStatsInteractor()
    private let (lifetime, token) = Lifetime.make()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator?.hideHeader = true
        self.tutorialIdentifier = "stats"
        
        let subscriber = Signal<CalculatedUserStats, NSError>.Observer(value: {[weak self] stats in
            self?.updateStats(stats)
        })
        
        disposable.inner.add(interactor.reactive.take(during: lifetime).observe(subscriber))
        
        disposable.inner.add(userRepository.getUser().flatMap(.latest, {[weak self] (user) in
            return self?.fetchGearStats(user: user) ?? SignalProducer.empty
        }).on(value: {[weak self] (user, gear) in
            self?.user = user
            self?.updateUser()
            self?.updateAutoAllocatonViews()
            if let stats = user.stats {
                self?.interactor.run(with: (stats, gear))
            }
        }).start())
        
        ThemeService.shared.addThemeable(themable: self, applyImmediately: true)
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
        
        strengthStatsView.allocateAction = { [weak self] in self?.allocate("str") }
        intelligenceStatsView.allocateAction = { [weak self] in self?.allocate("int") }
        constitutionStatsView.allocateAction = { [weak self] in self?.allocate("con") }
        perceptionStatsView.allocateAction = { [weak self] in self?.allocate("per") }
        
        distributeEvenlyHelpView.image = HabiticaIcons.imageOfInfoIcon()
        distributeClassHelpView.image = HabiticaIcons.imageOfInfoIcon()
        distributeTaskHelpView.image = HabiticaIcons.imageOfInfoIcon()
        
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
    }
    
    func applyTheme(theme: Theme) {
        distributeEvenlyCheckmark.image = HabiticaIcons.imageOfCheckmark(checkmarkColor: theme.tintColor, percentage: 1.0)
        distributeClassCheckmark.image = HabiticaIcons.imageOfCheckmark(checkmarkColor: theme.tintColor, percentage: 1.0)
        distributeTaskCheckmark.image = HabiticaIcons.imageOfCheckmark(checkmarkColor: theme.tintColor, percentage: 1.0)
    }
    
    private func allocate(_ attribute: String) {
        disposable.inner.add(userRepository.allocate(attributePoint: attribute).observeCompleted {})
    }
    
    private func updateUser() {
        guard let pointsToAllocate = user?.stats?.points else {
            return
        }
        let canAllocatePoints = pointsToAllocate != 0
        pointsToAllocateLeftView.isHidden = !canAllocatePoints
        pointsToAllocateRightView.isHidden = !canAllocatePoints
        if !canAllocatePoints {
            pointsToAllocateLabel.text = L10n.Stats.noPointsToAllocate
            pointsToAllocateLabel.backgroundColor = UIColor.white
            pointsToAllocateLabel.textColor = UIColor.gray300()
        } else {
            pointsToAllocateLabel.backgroundColor = UIColor.gray100()
            pointsToAllocateLabel.textColor = UIColor.white
            if pointsToAllocate == 1 {
                pointsToAllocateLabel.text = L10n.Stats.onePointToAllocate
            } else {
                pointsToAllocateLabel.text = L10n.Stats.pointsToAllocate(pointsToAllocate)
            }
        }
        strengthStatsView.canAllocatePoints = canAllocatePoints
        intelligenceStatsView.canAllocatePoints = canAllocatePoints
        constitutionStatsView.canAllocatePoints = canAllocatePoints
        perceptionStatsView.canAllocatePoints = canAllocatePoints
    }
    
    private func updateStats(_ stats: CalculatedUserStats) {
        totalStrength = stats.totalStrength
        totalIntelligence = stats.totalIntelligence
        totalConstitution = stats.totalConstitution
        totalPerception = stats.totalPerception
        
        strengthStatsView.levelValue = stats.levelStat
        intelligenceStatsView.levelValue = stats.levelStat
        constitutionStatsView.levelValue = stats.levelStat
        perceptionStatsView.levelValue = stats.levelStat
        
        strengthStatsView.buffValue = stats.buffStrength
        intelligenceStatsView.buffValue = stats.buffIntelligence
        constitutionStatsView.buffValue = stats.buffConstitution
        perceptionStatsView.buffValue = stats.buffPerception
        
        strengthStatsView.allocatedValue = stats.allocatedStrength
        intelligenceStatsView.allocatedValue = stats.allocatedIntelligence
        constitutionStatsView.allocatedValue = stats.allocatedConstitution
        perceptionStatsView.allocatedValue = stats.allocatedPerception
        
        strengthStatsView.equipmentValue = stats.gearWithBonusStrength
        intelligenceStatsView.equipmentValue = stats.gearWithBonusIntelligence
        constitutionStatsView.equipmentValue = stats.gearWithBonusConstitution
        perceptionStatsView.equipmentValue = stats.gearWithBonusPerception
    }
    
    private func fetchGearStats(user: UserProtocol) -> SignalProducer<(UserProtocol, [GearProtocol]), NoError> {
        var keys = [String]()
        if let outfit = user.items?.gear?.equipped {
            keys.append(outfit.armor ?? "")
            keys.append(outfit.back ?? "")
            keys.append(outfit.body ?? "")
            keys.append(outfit.eyewear ?? "")
            keys.append(outfit.head ?? "")
            keys.append(outfit.headAccessory ?? "")
            keys.append(outfit.weapon ?? "")
            keys.append(outfit.shield ?? "")
        }
        
        let gearProducer = inventoryRepository.getGear(predicate: NSPredicate(format: "key in %@", keys)).map({ gear in
            return gear.value
        }).flatMapError({ (_) -> SignalProducer<[GearProtocol], NoError> in
            return SignalProducer.empty
        })
        
        return gearProducer.withLatest(from: SignalProducer<UserProtocol, NoError>(value: user)).map({ (gear, user) in
            return (user, gear)
        })
    }
    
    private func updateAutoAllocatonViews() {
        let useAutoAllocation = user?.preferences?.automaticAllocation ?? false
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
        disposable.inner.add(userRepository.updateUser(key: "preferences.automaticAllocation", value: sender.isOn).observeCompleted {})
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
        updateAutoAllocatonViews()
        disposable.inner.add(userRepository.updateUser(key: "preferences.allocationMode", value: mode).observeCompleted {})
    }
    
    @objc
    func openBulkAssignView() {
        let viewController = BulkStatsAllocationViewController(nibName: "BulkStatsAllocationView", bundle: Bundle.main)
        let popup = PopupDialog(viewController: viewController, tapGestureDismissal: false) {
        }
    
        self.present(popup, animated: true, completion: nil)
    }
}
