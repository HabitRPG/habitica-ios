//
//  ChallengeDetailsTableViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/20/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import ReactiveSwift

class ChallengeDetailsTableViewController: MultiModelTableViewController {
    var viewModel: ChallengeDetailViewModel?
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topHeaderCoordinator?.hideHeader = true
        self.topHeaderCoordinator?.followScrollView = false
        
        title = "Details"

        if let viewModel = viewModel {
            disposable.inner.add(viewModel.cellModelsSignal.observeValues({[weak self] (sections) in
                self?.dataSource.sections = sections
                self?.tableView.reloadData()
            }))
            
            disposable.inner.add(viewModel.reloadTableSignal.observeValues {[weak self] _ in
                self?.tableView.reloadData()
            })
            
            disposable.inner.add(viewModel.animateUpdatesSignal.observeValues({[weak self]  _ in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }))
            
            disposable.inner.add(viewModel.nextViewControllerSignal.observeValues({[weak self] viewController in
                let navController = UINavigationController(rootViewController: viewController)
                navController.modalPresentationStyle = .pageSheet
                self?.navigationController?.present(navController, animated: true)
            }))
            
            disposable.inner.add(viewModel.joinLeaveStyleProvider.promptProperty.signal.observeValues({[weak self] prompt in
                if let alertController = prompt {
                    alertController.modalTransitionStyle = .crossDissolve
                    alertController.modalPresentationStyle = .overCurrentContext
                    self?.parent?.present(alertController, animated: true, completion: nil)
                }
            }))
            disposable.inner.add(viewModel.endChallengeStyleProvider.buttonPressedProperty.signal.observeValues({[weak self] _ in
                self?.endChallengeAction()
            }))
        }

        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "ChallengeTableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "header")
        tableView.separatorStyle = .none
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Asset.moreInteractionsIcon.image, menu: overflowMenu)
        
        self.viewModel?.viewDidLoad()
    }
    
    private var overflowMenu: UIMenu {
        return UIMenu(children: [
            UIMenu(options: .displayInline, children: [ UIDeferredMenuElement({ add in
                if self.viewModel?.challengeMembershipProperty.value != nil {
                    add([UIAction(title: L10n.leaveChallenge, image: UIImage(systemName: "person.badge.minus"), attributes: .destructive) { _ in
                        self.leaveChallenge()
                    }])
                } else {
                    add([UIAction(title: L10n.joinChallenge, image: UIImage(systemName: "person.badge.plus")) { _ in
                            self.joinChallenge()
                    }])
                }
            }) ]),
            UIAction(title: L10n.reportX(L10n.challenge), image: UIImage(systemName: "flag"), attributes: .destructive) { _ in
                if let challenge = self.viewModel?.challengeProperty.value {
                    let controller = FlagViewController(type: .challenge, offendingItem: challenge)
                    self.present(controller, animated: true)
                }
            }
        ])
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        tableView.backgroundColor = theme.contentBackgroundColor
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let dataSourceSection = dataSource.sections?[section] {
            if let sectionTitleString = dataSourceSection.title {
                if let itemCount = dataSourceSection.items?.count {
                    
                    let header: ChallengeTableViewHeaderView? = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? ChallengeTableViewHeaderView
                    
                    header?.titleLabel.text = sectionTitleString
                    header?.countLabel.text = "\(itemCount)"

                    return header
                }
            }
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataSource.sections?[section].title != nil ? 55 : 0
    }
    
    @objc
    private func joinChallenge() {
        guard let challenge = viewModel?.challengeProperty.value else {
            return
        }
        viewModel?.joinInteractor?.run(with: challenge)
    }
    
    @objc
    private func leaveChallenge() {
        guard let challenge = viewModel?.challengeProperty.value else {
            return
        }
        viewModel?.leaveInteractor?.run(with: challenge)
    }
    
    func endChallengeAction() {
        let alert = HabiticaAlertController(title: L10n.endChallenge, message: L10n.endChallengeDescription)
        alert.addAction(title: L10n.openWebsite, style: .default, isMainAction: true) { _ in
            let challengeID = self.viewModel?.challengeID ?? ""
            guard let url = URL(string: "https://habitica.com/challenges/\(challengeID)") else {
                return
            }
            UIApplication.shared.open(url)
        }
        alert.addCloseAction()
        alert.show()
    }
}
