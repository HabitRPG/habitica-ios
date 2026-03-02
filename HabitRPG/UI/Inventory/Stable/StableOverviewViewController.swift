//
//  StableOverviewViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class StableOverviewViewController<ANIMAL: AnimalProtocol, DS: StableOverviewDataSource<ANIMAL>>: BaseCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var datasource: DS?
    
    var organizeByColor = false
    
    private let headerView = NPCBannerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 124))
    private let headerStretcher = UIView()
    
    override func viewDidLoad() {
        let headerXib = UINib.init(nibName: "StableSectionHeader", bundle: .main)
        collectionView?.register(headerXib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        
        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        layout?.headerReferenceSize = CGSize(width: collectionView?.bounds.size.width ?? 50, height: 60)
        super.viewDidLoad()
        
        headerView.npcNameLabel.text = "Matt the Beast Master"
        headerView.setSprites(identifier: "stable")
        
        collectionView?.addSubview(headerView)
        collectionView?.addSubview(headerStretcher)
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        collectionView.backgroundColor = theme.contentBackgroundColor
        headerView.applyTheme(backgroundColor: theme.contentBackgroundColor)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let offset = collectionView.contentInset.top
        headerStretcher.frame = CGRect(x: 0, y: -offset, width: collectionView.frame.width, height: offset)
        headerView.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: headerView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.bounds.size.width, height: 184)
        } else {
            return CGSize(width: collectionView.bounds.size.width, height: 60)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let width = 102
        let safeLeft = collectionView.safeAreaInsets.left
        let safeRight = collectionView.safeAreaInsets.right
        let viewWidth = Int(collectionView.frame.size.width - safeLeft - safeRight)
        var count = 0
        var totalWidth = 0
        while (totalWidth + width + 14) < viewWidth {
            count += 1
            if totalWidth > 0 {
                totalWidth += 14
            }
            totalWidth += width
        }
        if let inSection = datasource?.collectionView(collectionView, numberOfItemsInSection: section) {
            if inSection < count {
                count = inSection
            }
        }
        let spacing = CGFloat(viewWidth - totalWidth) / 2
        let extraPadding: CGFloat = safeLeft > 0 ? 10 : 0
        return UIEdgeInsets(top: 0, left: spacing + safeLeft + extraPadding, bottom: 0, right: spacing + safeRight + extraPadding)
    }
}
