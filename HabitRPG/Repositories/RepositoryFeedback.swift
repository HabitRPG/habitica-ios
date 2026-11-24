import UIKit
import Habitica_Models

enum Haptic {
    case selection, success, error, tap
}

struct ScoreChange: Equatable {
    var health: Float
    var mana: Float
    var experience: Float
    var gold: Float
    var questDamage: Float
}

protocol RepositoryFeedback: AnyObject {
    func showToast(_ text: String, color: ToastColor, delay: TimeInterval)
    func showGoldEarned(_ gold: Float)
    func showArmoire(_ armoire: ArmoireResponseProtocol)
    func showPetHatched(_ pet: PetProtocol, equip: @escaping () -> Void)
    func showMountRaised(_ pet: PetProtocol, equip: @escaping () -> Void)
    func showMissingSaddle()
    func haptic(_ haptic: Haptic)
    func showScoreChange(_ change: ScoreChange)
    func showLevelUp()
    func showSkillUsed(_ name: String, mana: Int)
    func showQuestDamage(_ damage: Float)
    func showItemBroken(_ name: String)
    func showClassSelected(_ habiticaClass: HabiticaClass)
}

final class AppRepositoryFeedback: RepositoryFeedback {
    static let shared = AppRepositoryFeedback()

    func showToast(_ text: String, color: ToastColor, delay: TimeInterval) {
        guard delay > 0 else {
            ToastManager.show(text: text, color: color)
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            ToastManager.show(text: text, color: color)
        }
    }

    func showGoldEarned(_ gold: Float) {
        ToastManager.show(toast: ToastView(goldDiff: gold, background: .green, delay: 0.5))
    }

    func showArmoire(_ armoire: ArmoireResponseProtocol) {
        let viewController = ArmoireViewController()
        viewController.configure(type: armoire.type ?? "", text: armoire.dropText ?? "", key: armoire.dropKey, value: armoire.value)
        viewController.showFullscreen(delay: 1.5)
    }

    func showPetHatched(_ pet: PetProtocol, equip: @escaping () -> Void) {
        HostingBottomSheetController(rootView: PetHatchedSheet(pet: pet, onEquip: equip), prefersGrabberVisible: false).show()
    }

    func showMountRaised(_ pet: PetProtocol, equip: @escaping () -> Void) {
        HostingBottomSheetController(rootView: MountRaisedSheet(mount: pet, onEquip: equip), prefersGrabberVisible: false).show()
    }

    func showMissingSaddle() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let alert = HabiticaAlertController(title: L10n.Inventory.noSaddleTile, message: L10n.Inventory.noSaddleDescription)
            alert.addAction(title: L10n.Inventory.visitMarket, style: .default, isMainAction: true) { _ in
                RouterHandler.shared.handle(urlString: "/inventory/market/food")
            }
            alert.addCloseAction()
            alert.show()
        }
    }

    func haptic(_ haptic: Haptic) {
        switch haptic {
        case .selection:
            UISelectionFeedbackGenerator.oneShotSelectionChanged()
        case .success:
            UINotificationFeedbackGenerator.oneShotNotificationOccurred(.success)
        case .error:
            UINotificationFeedbackGenerator.oneShotNotificationOccurred(.error)
        case .tap:
            UIImpactFeedbackGenerator.oneShotImpactOccurred(.light)
        }
    }

    func showScoreChange(_ change: ScoreChange) {
        ToastManager.show(toast: ToastView(healthDiff: change.health,
                                           magicDiff: change.mana,
                                           expDiff: change.experience,
                                           goldDiff: change.gold,
                                           questDamage: change.questDamage,
                                           background: change.health >= 0 ? .green : .red))
    }

    func showLevelUp() {
        HostingBottomSheetController(rootView: LevelupSheet(), prefersGrabberVisible: false).show()
        SoundManager.shared.play(effect: .levelUp)
    }

    func showSkillUsed(_ name: String, mana: Int) {
        ToastManager.show(toast: ToastView(title: L10n.Skills.useSkill(name),
                                           rightIcon: HabiticaIcons.imageOfMagic,
                                           rightText: "-\(mana)",
                                           rightTextColor: UIColor.blue10,
                                           background: .blue,
                                           delay: 0.5))
    }

    func showQuestDamage(_ damage: Float) {
        ToastManager.show(toast: ToastView(title: L10n.Skills.causedDamage,
                                           rightIcon: HabiticaIcons.imageOfDamage,
                                           rightText: "+\(damage)",
                                           rightTextColor: UIColor.green10,
                                           background: .green,
                                           delay: 0.5))
    }

    func showItemBroken(_ name: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            ToastManager.show(text: "Your \(name) broke", color: .black, duration: 3.0)
        }
    }

    func showClassSelected(_ habiticaClass: HabiticaClass) {
        let viewController = HostingBottomSheetController(rootView: ClassConfirmationSheet(selectedClass: habiticaClass), prefersGrabberVisible: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            viewController.show()
        }
        UIApplication.requestReview()
    }
}
