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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Asset.moreInteractionsIcon.image, style: .plain, target: self, action: #selector(showOverflowMenu))
        
        self.viewModel?.viewDidLoad()
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
    
    @IBAction func showOverflowMenu(_ sender: Any) {
        let sheet = HostingBottomSheetController(rootView: BottomSheetMenu(menuItems: {
            BottomSheetMenuitem(title: L10n.reportX(L10n.challenge), style: .destructive) {
                if let challenge = self.viewModel?.challengeProperty.value {
                    FlagViewController(type: .challenge, offendingItem: challenge).show()
                }
            }
            BottomSheetMenuSeparator()
            let isMember = viewModel?.challengeMembershipProperty.value != nil
            if !isMember {
                BottomSheetMenuitem(title: L10n.joinChallenge) {
                    self.joinChallenge()
                }
            } else if isMember {
                BottomSheetMenuitem(title: L10n.leaveChallenge, style: .destructive) {
                    self.leaveChallenge()
                }
           }
        }))
        present(sheet, animated: true)
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
