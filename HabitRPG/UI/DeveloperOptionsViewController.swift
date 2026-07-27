//
//  DeveloperOptionsViewController.swift
//  Habitica
//
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//

import UIKit

class DeveloperOptionsViewController: BaseTableViewController {

    private enum OptionRow {
        case promo(key: String, title: String)
        case season(key: String, title: String)
        case flag(index: Int)
    }

    private struct Section {
        let title: String
        let footer: String?
        let rows: [OptionRow]
    }

    private let configRepository = ConfigRepository.shared

    private let seasons: [(key: String, title: String)] = [
        ("winter", "Winter"),
        ("spring", "Spring"),
        ("summer", "Summer"),
        ("fall", "Fall"),
        ("nye", "New Year's Eve"),
        ("birthday", "Birthday"),
        ("valentines", "Valentines"),
        ("habitoween", "Habitoween"),
        ("thanksgiving", "Thanksgiving")
    ]

    private let flags: [(key: String, title: String)] = [
        (DeveloperOverride.notificationDots, "Red dots + row subtitles"),
        (DeveloperOverride.rowBadges, "Row chips / badges"),
        (DeveloperOverride.lockedRows, "Locked rows + lock chip")
    ]

    private var sections = [Section]()

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildSections()
        tableView.reloadData()
    }

    override func populateText() {
        navigationItem.title = "Developer Options"
    }

    private func buildSections() {
        var promoRows: [OptionRow] = [.promo(key: "", title: "Off (use live config)")]
        promoRows.append(contentsOf: HabiticaPromotionType.selectableKeys.map { OptionRow.promo(key: $0.key, title: $0.title) })

        var seasonRows: [OptionRow] = [.season(key: "", title: "Off (use live config)")]
        seasonRows.append(contentsOf: seasons.map { OptionRow.season(key: $0.key, title: $0.title) })

        sections = [
            Section(title: "Promotion",
                    footer: "Drives the pinned pill at the top of the menu and the banner card at the bottom.",
                    rows: promoRows),
            Section(title: "Seasonal Shop",
                    footer: "Drives the Seasonal Shop row icon and its badge text.",
                    rows: seasonRows),
            Section(title: "Cosmetic States (QA)",
                    footer: "Display only. These change how rows are drawn and never create parties, messages or purchases.",
                    rows: flags.indices.map { OptionRow.flag(index: $0) })
        ]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footer
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let theme = ThemeService.shared.theme
        cell.backgroundColor = theme.windowBackgroundColor
        cell.textLabel?.textColor = theme.primaryTextColor
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .none
        cell.accessoryView = nil

        switch sections[indexPath.section].rows[indexPath.row] {
        case .promo(let key, let title):
            cell.textLabel?.text = title
            cell.accessoryType = (configRepository.developerPromoOverride ?? "") == key ? .checkmark : .none
        case .season(let key, let title):
            cell.textLabel?.text = title
            cell.accessoryType = (configRepository.developerSeasonOverride ?? "") == key ? .checkmark : .none
        case .flag(let index):
            let flag = flags[index]
            cell.textLabel?.text = flag.title
            cell.selectionStyle = .none
            let toggle = UISwitch()
            toggle.isOn = configRepository.developerFlag(flag.key)
            toggle.tag = index
            toggle.addTarget(self, action: #selector(flagToggled(_:)), for: .valueChanged)
            cell.accessoryView = toggle
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section].rows[indexPath.row] {
        case .promo(let key, _):
            configRepository.developerPromoOverride = key
        case .season(let key, _):
            configRepository.developerSeasonOverride = key
        case .flag:
            return
        }
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
    }

    @objc
    private func flagToggled(_ sender: UISwitch) {
        configRepository.setDeveloperFlag(sender.isOn, forKey: flags[sender.tag].key)
    }
}
