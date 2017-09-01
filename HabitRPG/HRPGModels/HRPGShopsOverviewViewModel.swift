//
//  HRPGShopsOverviewViewModel.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/23/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

@objc protocol HRPGShopsOverviewViewModelDelegate: class {
    func didFetchShops()
}

class HRPGShopsOverviewViewModel: NSObject, HRPGShopOverviewTableViewDataSourceDelegate {
    lazy var shopDictionary: [AnyHashable: Any]? = [AnyHashable: Any]()
    weak var delegate: HRPGShopsOverviewViewModelDelegate?
    
    func fetchShops() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        if let context = HRPGManager.shared().getManagedObjectContext() {
            let entity = NSEntityDescription.entity(forEntityName: "Shop", in: context)
            fetchRequest.entity = entity
        }
        
        do {
            if let shops: [Shop] = try HRPGManager.shared().getManagedObjectContext().fetch(fetchRequest) as? [Shop], shops.count != 0 {
                for shop in shops {
                    if let identifier = shop.identifier {
                        shopDictionary?[identifier] = shop
                    }
                }
                
                delegate?.didFetchShops()
            } else {
                refreshShops()
            }
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    func refreshShops() {
        var semaphore = 4
        let success: (() -> Void) = {
            semaphore -= 1
            self.checkFetchedSemaphore(semaphore: semaphore)
        }
        
        refreshShop(withIdentifier: MarketKey, onSuccess: success, onError: nil)
        refreshShop(withIdentifier: QuestsShopKey, onSuccess: success, onError: nil)
        refreshShop(withIdentifier: SeasonalShopKey, onSuccess: success, onError: nil)
        refreshShop(withIdentifier: TimeTravelersShopKey, onSuccess: success, onError: nil)
    }
    
    private func checkFetchedSemaphore(semaphore: Int) {
        if semaphore == 0 {
            fetchShops()
        }
    }

    // MARK: - datasource delegate
    
    func refreshShop(withIdentifier identifier: String?, onSuccess successBlock: (() -> Void)?, onError errorBlock: (() -> Void)?) {
        HRPGManager.shared().fetchShopInventory(identifier, onSuccess: {
            if let success = successBlock {
                success()
            }
        }, onError: errorBlock)
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
