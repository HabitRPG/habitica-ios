//
//  StableDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class StableDetailViewController<DS>: HRPGCollectionViewController {
    
    var datasource: DS?
    
    var disposable = ScopedDisposable(CompositeDisposable())
    
    override func viewDidLoad() {
        let headerXib = UINib.init(nibName: "StableSectionHeader", bundle: .main)
        collectionView?.register(headerXib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        
        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        layout?.headerReferenceSize = CGSize(width: collectionView?.bounds.size.width ?? 50, height: 60)
        super.viewDidLoad()
    }
}
