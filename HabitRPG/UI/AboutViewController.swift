//
//  AboutViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 09.10.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Realm
import VTAcknowledgementsViewController
import Habitica_Models
import MessageUI

class AboutViewController: BaseTableViewController, MFMailComposeViewControllerDelegate {
    
    private let configRepository = ConfigRepository()
    private let userRepository = UserRepository()
    
    private var selectedIndexPath: IndexPath?
    private var supportEmail = ""
    private var user: UserProtocol?
    
    private let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"]
    
    private lazy var appVersionString: String = {
        return "\(versionString ?? "") (\(buildNumber ?? ""))"
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator.hideHeader = true
        topHeaderCoordinator.followScrollView = false
        let headerImageView = UIImageView(frame: CGRect(x: 0, y: 10, width: view.frame.size.width, height: 130))
        headerImageView.image = Asset.gryphon.image.withRenderingMode(.alwaysTemplate)
        headerImageView.tintColor = ThemeService.shared.theme.backgroundTintColor
        headerImageView.contentMode = .center
        headerImageView.addHeightConstraint(height: 130)
        tableView.tableHeaderView = headerImageView
                
        supportEmail = configRepository.string(variable: .supportEmail, defaultValue: "admin@habitica.com")
        
        userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
        }).start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = .clear
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.about
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if section == 0 {
            count = 1
            if needsUpdate() {
                count += 1
            }
        } else if section == 1 {
            count = 3
        } else if section == 2 {
            count = 2
        } else if section == 3 {
            count = 2
            if !HabiticaAppDelegate.isRunningLive() {
                count += 1
            }
        }
        
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellStyle = UITableViewCell.CellStyle.default
        if indexPath.section == 0 || indexPath.section == 2 {
            cellStyle = UITableViewCell.CellStyle.value1
        }
        let cell = UITableViewCell(style: cellStyle, reuseIdentifier: "Cell")
        cell.accessoryType = .none
        cell.selectionStyle = .default
        cell.textLabel?.font = CustomFontMetrics.scaledSystemFont(ofSize: cell.textLabel?.font.pointSize ?? 14)
        let theme = ThemeService.shared.theme
        cell.textLabel?.textColor = theme.primaryTextColor
        cell.detailTextLabel?.textColor = theme.secondaryTextColor
        if indexPath.section == 0 {
            if needsUpdate() && indexPath.item == 1 {
                cell.textLabel?.text = L10n.About.newVersion(configRepository.string(variable: .lastVersionNumber) ?? "")
                cell.textLabel?.textColor = theme.tintColor
                cell.textLabel?.font = CustomFontMetrics.scaledBoldSystemFont(ofSize: cell.textLabel?.font.pointSize ?? 14)
                cell.detailTextLabel?.text = L10n.About.whatsNew
                cell.detailTextLabel?.textColor = theme.tintColor
            } else if indexPath.item == 0 {
                cell.textLabel?.text = L10n.About.version
                cell.detailTextLabel?.text = appVersionString
            }
        } else if indexPath.section == 1 {
            if indexPath.item == 0 {
                cell.textLabel?.text = L10n.About.sendFeedback
            } else if indexPath.item == 1 {
                cell.textLabel?.text = L10n.About.reportBug
            } else if indexPath.item == 2 {
                cell.textLabel?.text = L10n.About.leaveReview
            }
        } else if indexPath.section == 2 {
            if indexPath.item == 0 {
                cell.textLabel?.text = L10n.About.website
                cell.detailTextLabel?.text = "habitica.com"
            } else if indexPath.item == 1 {
                cell.textLabel?.text = "Twitter"
                cell.detailTextLabel?.text = "@habitica"
            }
        } else if indexPath.section == 3 {
            if indexPath.item == 0 {
                cell.textLabel?.text = L10n.About.viewSourceCode
            } else if indexPath.item == 1 {
                cell.textLabel?.text = L10n.About.acknowledgements
            } else if indexPath.item == 2 {
                cell.textLabel?.text = L10n.About.exportDatabase
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath

        if indexPath.section == 0 {
            if needsUpdate() && indexPath.item == 1 {
                open(url: "itms-apps://itunes.apple.com/app/id994882113")
            }
        } else if indexPath.section == 1 {
            if indexPath.item == 0 {
                handleAppFeedback()
            } else if indexPath.item == 1 {
                handleBugReport()
            } else if indexPath.item == 2 {
                open(url: "itms-apps://itunes.apple.com/app/id994882113")
            }
        } else if indexPath.section == 2 {
            if indexPath.item == 0 {
                open(url: "https://habitica.com/")
            } else if indexPath.item == 1 {
                open(url: "https://twitter.com/habitica")
            }
        } else if indexPath.section == 3 {
            if indexPath.item == 0 {
                open(url: "https://github.com/habitRPG/habitica-ios")
            } else if indexPath.item == 1 {
                if let viewController = VTAcknowledgementsViewController.acknowledgementsViewController() {
                    viewController.headerText = L10n.About.loveOpenSource
                    navigationController?.pushViewController(viewController, animated: true)
                }
            } else if indexPath.item == 2 {
                if let url = RLMRealmConfiguration.default().fileURL {
                    let activityViewController = UIActivityViewController.init(activityItems: [url], applicationActivities: nil)
                    present(activityViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func open(url urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func handleAppFeedback() {
        open(url: configRepository.string(variable: .feedbackURL) ?? "")
    }
    
    private func handleBugReport() {
        sendEmail(subject: "[iOS] Bugreport")
    }
    
    private func sendEmail(subject: String) {
        if MFMailComposeViewController.canSendMail() {
            let composeViewController = MFMailComposeViewController(nibName: nil, bundle: nil)
            composeViewController.mailComposeDelegate = self
            composeViewController.setToRecipients([supportEmail])
            composeViewController.setSubject(subject)
            composeViewController.setMessageBody(createDeviceInformationString(), isHTML: false)
            present(composeViewController, animated: true, completion: nil)
        } else {
            showNoEmailAlert()
        }
    }
    
    private func showNoEmailAlert() {
        let alert = HabiticaAlertController(title: L10n.About.noEmailTitle, message: L10n.About.noEmailMessage(supportEmail))
        alert.addCloseAction()
        alert.show()
    }
    
    private func createDeviceInformationString() -> String {
        var informationString = "Please describe the bug you encountered:\n\n\n\n\n\n\n\n\n\n\n\n"
        informationString.append("The following lines help us find and squash the Bug you encountered. Please do not delete/change them.\n")
        informationString.append("iOS Version: \(UIDevice.current.systemVersion)\n")
        informationString.append("Device: \(UIDevice.modelName)\n")
        informationString.append("App Version: \(appVersionString)\n")
        informationString.append("User ID: \(AuthenticationManager.shared.currentUserId ?? "")\n")
        if let user = self.user {
            if let level = user.stats?.level {
                informationString.append("Level: \(level)\n")
            }
            if let disableClass = user.preferences?.disableClasses {
                if disableClass {
                    informationString.append("Class: Disabled\n")
                } else {
                    if let habitClass = user.stats?.habitClassNice {
                        informationString.append("Class: \(habitClass)\n")
                    }
                }
            }
            if let sleep = user.preferences?.sleep {
                informationString.append("Is in Inn: \(sleep)\n")
            }
            if let useCostume = user.preferences?.useCostume {
                informationString.append("Uses Costume: \(useCostume)\n")
            }
            if let cds = user.preferences?.dayStart {
                informationString.append("Custom Day Start: \(cds)\n")
            }
        }
        return informationString
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
        if let indexPath = selectedIndexPath {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    private func needsUpdate() -> Bool {
        return (buildNumber as? NSString)?.intValue ?? 0 < configRepository.integer(variable: .lastVersionCode)
    }
}
