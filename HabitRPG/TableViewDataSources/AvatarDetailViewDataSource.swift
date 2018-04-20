//
//  AvatarDetailViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class AvatarDetailViewDataSource: BaseReactiveCollectionViewDataSource<CustomizationProtocol> {
    
    private let customizationRepository = CustomizationRepository()
    private let userRepository = UserRepository()
    
    var customizationGroup: String?
    var customizationType: String
    
    private var preferences: PreferencesProtocol?
    
    init(type: String, group: String?) {
        self.customizationType = type
        self.customizationGroup = group
        super.init()
        sections.append(ItemSection<CustomizationProtocol>())
        
        disposable.inner.add(customizationRepository.getCustomizations(type: customizationType, group: customizationGroup).on(value: { (customizations, changes) in
            self.sections[0].items = customizations
            self.notify(changes: changes)
        }).start())
        disposable.inner.add(userRepository.getUser().on(value: { user in
            self.preferences = user.preferences
        }).start())
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        if let customization = item(at: indexPath) {
            let imageView = cell.viewWithTag(1) as? UIImageView
            imageView?.setImagewith(name: customization.imageName(forUserPreferences: preferences))
        }
        
        return cell
    }
}
