//
//  HallOfPatronsDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class HallOfPatronsDataSource: BaseReactiveTableViewDataSource<MemberProtocol> {
    
    private let contentRepository = ContentRepository()
    
    override init() {
        super.init()
        sections.append(ItemSection<MemberProtocol>())
        fetchNotifications()
    }

    private func fetchNotifications() {
        disposable.add(contentRepository.retrieveHallOfPatrons().observeValues {[weak self] entries in
            self?.sections[0].items = entries ?? []
            self?.tableView?.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let member = item(at: indexPath)
        cell.textLabel?.text = member?.profile?.name ?? member?.username
        cell.detailTextLabel?.text = L10n.backerTier(member?.backer?.tier ?? 0)
        return cell
    }
}
