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
        if (tableView.indexPathsForVisibleRows?.count ?? 0) == 0 {
            return
        }
        if tableView.indexPathsForVisibleRows?.contains(where: { indexPath -> Bool in
            return indexPath.section == 0 && indexPath.item == 0
        }) == true {
            if navigationItem.rightBarButtonItem != nil {
                navigationItem.rightBarButtonItem = nil
            }
        } else if viewModel?.challengeMembershipProperty.value == nil && navigationItem.rightBarButtonItem == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.join, style: .plain, target: self, action: #selector(joinChallenge))
        }
    }
    
    @objc
    private func joinChallenge() {
        
    }
}
