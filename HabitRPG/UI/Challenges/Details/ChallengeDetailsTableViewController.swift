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
        self.topHeaderCoordinator.hideHeader = true
        self.topHeaderCoordinator.followScrollView = false
        
        title = "Details"

        if let viewModel = viewModel {
            disposable.inner.add(viewModel.cellModelsSignal.observeValues({[weak self] (sections) in
                self?.dataSource.sections = sections
                self?.tableView.reloadData()
                self?.updateNavbarButton()
            }))
            
            disposable.inner.add(viewModel.reloadTableSignal.observeValues {[weak self] _ in
                self?.tableView.reloadData()
            })
            
            disposable.inner.add(viewModel.animateUpdatesSignal.observeValues({[weak self]  _ in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }))
            
            disposable.inner.add(viewModel.nextViewControllerSignal.observeValues({[weak self] viewController in
                self?.navigationController?.pushViewController(viewController, animated: true)
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavbarButton()
    }
    
    private func updateNavbarButton() {
         if (tableView.indexPathsForVisibleRows?.count ?? 0) == 0 {
             return
         }
         let isMember = viewModel?.challengeMembershipProperty.value != nil
         var indexPath = IndexPath(item: 0, section: 0)
         if isMember {
             indexPath = IndexPath(item: 0, section: tableView.numberOfSections-1)
         }
         if tableView.isVisible(indexPath: indexPath) {
             if navigationItem.rightBarButtonItem != nil {
                 navigationItem.rightBarButtonItem = nil
             }
         } else if !isMember && navigationItem.rightBarButtonItem?.title != L10n.join {
             navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.join, style: .plain, target: self, action: #selector(joinChallenge))
         } else if isMember && navigationItem.rightBarButtonItem?.title != L10n.leave {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.leave, style: .plain, target: self, action: #selector(leaveChallenge))
        }
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
