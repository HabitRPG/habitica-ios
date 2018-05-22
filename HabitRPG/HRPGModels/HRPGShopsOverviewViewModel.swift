//
//  HRPGShopsOverviewViewModel.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/23/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import ReactiveSwift
@objc protocol HRPGShopsOverviewViewModelDelegate: class {
    func didFetchShops()
}

class HRPGShopsOverviewViewModel: NSObject, HRPGShopOverviewTableViewDataSourceDelegate {
    lazy var shopDictionary: [AnyHashable: Any]? = [AnyHashable: Any]()
    @objc weak var delegate: HRPGShopsOverviewViewModelDelegate?
    
    private var inventoryRepository = InventoryRepository()
    
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    @objc
    func fetchShops() {
        disposable.inner.add(inventoryRepository.getShops().on(value: { (shops, _) in
            for shop in shops {
                if let identifier = shop.identifier {
                    self.shopDictionary?[identifier] = shop
                }
            }
            
            self.delegate?.didFetchShops()
        }).start())
    }
    
    @objc
    func refreshShops() {
        refreshShop(withIdentifier: MarketKey)
        refreshShop(withIdentifier: QuestsShopKey)
        refreshShop(withIdentifier: SeasonalShopKey)
        refreshShop(withIdentifier: TimeTravelersShopKey)
    }

    // MARK: - datasource delegate
    
    @objc
    func refreshShop(withIdentifier identifier: String) {
        inventoryRepository.retrieveShopInventory(identifier: identifier).observeCompleted {}
    }
    
    func identifier(at index: Int) -> String? {
        switch index {
        case 0:
            return MarketKey
        case 1:
            return QuestsShopKey
        case 2:
            return SeasonalShopKey
        case 3:
            return TimeTravelersShopKey
        default:
            return nil
        }
    }
}
