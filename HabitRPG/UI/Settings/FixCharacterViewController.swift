//
//  FixCharacterViewController.swift
//  Habitica
//
//  Created by Phillip on 25.10.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift

class FixCharacterViewController: BaseTableViewController {
    
    let disposable = ScopedDisposable(CompositeDisposable())
    
    let userRepository = UserRepository()
    
    var stats: [String: Encodable] = [
        "stats.hp": 0.0,
        "stats.exp": 0.0,
        "stats.mp": 0.0,
        "stats.gp": 0.0,
        "stats.lvl": 0,
        "achievements.streak": 0
    ]
    
    private var headerView = UIView()
    private var headerLabel = UILabel()
    
    var habitClass = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = L10n.Titles.fixValues
        
        headerLabel.text = L10n.Settings.fixValuesDescription
        headerLabel.font = .systemFont(ofSize: 15)
        headerLabel.numberOfLines = 0
        headerLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 26),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -26),
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10)
        ])
        
        tableView.tableHeaderView = headerView
        
        DispatchQueue.main.async {
            self.sizeHeaderToFit()
        }
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.stats["stats.hp"] = user.stats?.health
            self?.stats["stats.exp"] = user.stats?.experience
            self?.stats["stats.mp"] = user.stats?.mana
            self?.stats["stats.gp"] = user.stats?.gold
            self?.stats["stats.lvl"] = user.stats?.level
            self?.stats["achievements.streak"] = user.achievements?.streak
            self?.habitClass = user.stats?.habitClass ?? ""
            self?.tableView.reloadData()
        }).start())
    }
    
    private func sizeHeaderToFit() {
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        headerView.frame.size.width = tableView.bounds.width
        let size = headerView.systemLayoutSizeFitting(
            CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: UILayoutPriority.required,
            verticalFittingPriority: UILayoutPriority.fittingSizeLevel
        )
        headerView.frame.size.height = size.height
        tableView.tableHeaderView = headerView
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        headerView.backgroundColor = theme.contentBackgroundColor
        tableView.backgroundColor = theme.contentBackgroundColor
        headerLabel.textColor = theme.primaryTextColor
    }
    
    private func identifierFor(index: Int) -> String {
        switch index {
        case 0:
            return "stats.hp"
        case 1:
            return "stats.exp"
        case 2:
            return "stats.mp"
        case 3:
            return "stats.gp"
        case 4:
            return "stats.lvl"
        case 5:
            return "achievements.streak"
        default:
            return ""
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let titleLabel = cell.viewWithTag(1) as? UILabel,
            let iconView = cell.viewWithTag(3) as? UIImageView,
            let valueField = cell.viewWithTag(2) as? UITextField {
            configure(item: indexPath.item, titleLabel: titleLabel, iconView: iconView, valueField: valueField)
            valueField.textColor = ThemeService.shared.theme.primaryTextColor
        }
        if let wrapper = cell.viewWithTag(4) {
            wrapper.borderWidth = 0
            wrapper.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
            wrapper.cornerRadius = 13
        }
        
        return cell
    }
    
    private func configure(item: Int, titleLabel: UILabel, iconView: UIImageView, valueField: UITextField) {
        let value = stats[identifierFor(index: item)]
        if let intValue = value as? Int {
            valueField.text = String(intValue)
            valueField.keyboardType = .numberPad
        } else if let floatValue = value as? Float {
            valueField.text = "\(floatValue)"
            valueField.keyboardType = .decimalPad
        }
        let isDark = ThemeService.shared.theme.isDark
        switch item {
        case 0:
            titleLabel.text = L10n.health
            titleLabel.textColor = isDark ? .red500 : .red10
            iconView.image = HabiticaIcons.imageOfHeartLightBg
            return
        case 1:
            titleLabel.text = L10n.experience
            titleLabel.textColor = isDark ? .yellow500 : .yellow10
            iconView.image = HabiticaIcons.imageOfExperience
            return
        case 2:
            titleLabel.text = L10n.manaPoints
            titleLabel.textColor = isDark ? .blue500 : .blue10
            iconView.image = HabiticaIcons.imageOfMagic
            return
        case 3:
            titleLabel.text = L10n.gold
            titleLabel.textColor = isDark ? .orange500 : .yellow10
            iconView.image = HabiticaIcons.imageOfGold
            return
        case 4:
            titleLabel.text = L10n.characterLevel
            titleLabel.textColor = isDark ? .purple500 : .purple300
            configure(iconView: iconView, forHabitClass: habitClass)
            return
        case 5:
            titleLabel.text = L10n.dayStreaks
            titleLabel.textColor = ThemeService.shared.theme.primaryTextColor
            iconView.image = Asset.Menu.badge.image
            return
        default:
            return
        }
    }
    
    @IBAction func savePressed(_ sender: Any) {
        for stat in stats {
            if let value = stat.value as? Int {
                stats[stat.key] = min(10000, value)
            } else if let value = stat.value as? Float {
                stats[stat.key] = min(10000.0, value)
            }
        }
        userRepository.updateUser(stats).observeCompleted {[weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        if let cell = sender.superview?.superview?.superview as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            let value = stats[identifierFor(index: indexPath.item)]
            if value is Int {
                stats[identifierFor(index: indexPath.item)] = Int(sender.text ?? "") ?? Float(sender.text ?? "") ?? 0
            } else if value is Float {
                stats[identifierFor(index: indexPath.item)] = Float(sender.text ?? "") ?? 0
            }
        }
    }
    
    func configure(iconView: UIImageView, forHabitClass habitClass: String) {
        switch habitClass {
        case "warrior":
            iconView.image = HabiticaIcons.imageOfWarriorLightBg
            return
        case "wizard":
            iconView.image = HabiticaIcons.imageOfMageLightBg
            return
        case "healer":
            iconView.image = HabiticaIcons.imageOfHealerLightBg
            return
        case "rogue":
            iconView.image = HabiticaIcons.imageOfRogueLightBg
            return
        default:
            return
        }
    }
}
