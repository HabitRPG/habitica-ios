//
//  ChallengeDetailsTableViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/20/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import SwiftUI
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
            UIMenu(options: .displayInline, children: [ UIDeferredMenuElement({ [weak self] add in
                if self?.viewModel?.challengeMembershipProperty.value != nil {
                    add([UIAction(title: L10n.leaveChallenge, image: UIImage(systemName: "person.badge.minus"), attributes: .destructive) { [weak self] _ in
                        self?.leaveChallenge()
                    }])
                } else {
                    add([UIAction(title: L10n.joinChallenge, image: UIImage(systemName: "person.badge.plus")) { [weak self] _ in
                            self?.joinChallenge()
                    }])
                }
            }) ]),
            UIAction(title: L10n.reportX(L10n.challenge), image: UIImage(systemName: "flag"), attributes: .destructive) { [weak self] _ in
                self?.reportChallenge()
            },
            UIDeferredMenuElement({ [weak self] add in
                guard self?.viewModel?.challengeProperty.value?.isOwner(AuthenticationManager.shared.currentUserId) == true else {
                    add([])
                    return
                }
                add([UIMenu(title: L10n.ownerActions, options: .displayInline, children: [
                    UIAction(title: L10n.endChallenge, image: UIImage(systemName: "trophy")) { [weak self] _ in self?.endChallengeAction() },
                    UIAction(title: L10n.viewProgress, image: UIImage(systemName: "doc.text")) { [weak self] _ in self?.viewProgressAction() },
                    UIAction(title: L10n.exportChallenge, image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in self?.exportChallengeAction() },
                    UIAction(title: L10n.cloneChallenge, image: UIImage(systemName: "plus.square.on.square")) { [weak self] _ in self?.cloneChallengeAction() },
                    UIAction(title: L10n.editChallenge, image: UIImage(systemName: "pencil")) { [weak self] _ in self?.editChallengeAction() }
                ])])
            })
        ])
    }

    private func reportChallenge() {
        if let challenge = viewModel?.challengeProperty.value {
            let controller = FlagViewController(type: .challenge, offendingItem: challenge)
            present(controller, animated: true)
        }
    }

    func viewProgressAction() {
        guard let challenge = viewModel?.challengeProperty.value else { return }
        let host = UIHostingController(rootView: CheckParticipationView(challenge: challenge, onClose: { [weak self] in
            self?.dismiss(animated: true)
        }))
        host.modalPresentationStyle = .fullScreen
        present(host, animated: true)
    }

    func exportChallengeAction() {
        let challengeID = viewModel?.challengeID ?? ""
        guard let url = URL(string: "https://habitica.com/challenges/\(challengeID)") else { return }
        UIApplication.shared.open(url)
    }

    func editChallengeAction() {
        guard let challenge = viewModel?.challengeProperty.value else { return }
        let viewController = CreateChallengeViewController()
        viewController.prepareForEditing(challenge: challenge)
        viewController.modalPresentationStyle = .formSheet
        viewController.isModalInPresentation = true
        present(viewController, animated: true)
    }

    func cloneChallengeAction() {
        guard let challenge = viewModel?.challengeProperty.value else { return }
        let viewController = CreateChallengeViewController()
        viewController.prepareForCloning(challenge: challenge)
        viewController.modalPresentationStyle = .formSheet
        viewController.isModalInPresentation = true
        present(viewController, animated: true)
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        tableView.backgroundColor = theme.contentBackgroundColor
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let dataSourceSection = dataSource.sections?[section] {
            if let sectionTitleString = dataSourceSection.title {
                if dataSourceSection.items?.isEmpty == false {
                    
                    let header: ChallengeTableViewHeaderView? = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? ChallengeTableViewHeaderView
                    
                    header?.titleLabel.text = sectionTitleString
                    header?.titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
                    header?.titleLabel.textColor = UIColor(red: 144 / 255, green: 141 / 255, blue: 152 / 255, alpha: 1)
                    header?.countLabel.text = nil
                    header?.countLabel.isHidden = true

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
        guard let challenge = viewModel?.challengeProperty.value else { return }
        let host = UIHostingController(rootView: EndChallengeFlow(challenge: challenge, onClose: { [weak self] in
            self?.dismiss(animated: true)
        }))
        if let sheet = host.sheetPresentationController {
            let compact = UISheetPresentationController.Detent.custom(identifier: .init("endChallengeCompact")) { context in
                min(760, context.maximumDetentValue)
            }
            sheet.detents = [compact, .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 30
        }
        present(host, animated: true)
    }
}
