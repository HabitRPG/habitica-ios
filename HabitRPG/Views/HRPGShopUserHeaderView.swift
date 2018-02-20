//
//  HRPGShopUserHeaderView.swift
//  Habitica
//
//  Created by Elliot Schrock on 7/13/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class HRPGShopUserHeaderView: UIView, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var userClassImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var hourglassCountView: HRPGCurrencyCountView!
    @IBOutlet weak var gemCountView: HRPGCurrencyCountView!
    @IBOutlet weak var goldCountView: HRPGCurrencyCountView!
    
    lazy var manager: HRPGManager? = {
        HRPGManager.shared()
    }()
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = {
        return self.createFetchedResultsController()
    }()
    lazy var managedObjectContext: NSManagedObjectContext? = self.manager?.getManagedObjectContext()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetUser), name: NSNotification.Name(rawValue: "userChanged"), object: nil)
    }
    
    override func awakeFromNib() {
        hourglassCountView.currency = .hourglass
        gemCountView.currency = .gem
        goldCountView.currency = .gold
        setData()
        super.awakeFromNib()
    }
    
    @objc
    func resetUser() {
        fetchedResultsController = createFetchedResultsController()
        setData()
    }
    
    func setData() {
        if let user = getUser() {
            usernameLabel.text = user.username
            usernameLabel.textColor = user.contributorColor()
            
            if let shouldDisable = user.preferences?.disableClass, !shouldDisable.boolValue, let userClass = user.hclass {
                userClassImageView.isHidden = false
                userClassImageView.image = UIImage(named: "icon_\(userClass)")
            } else {
                userClassImageView.isHidden = true
            }
            
            goldCountView.amount = user.gold.intValue
            gemCountView.amount = Int(user.balance.floatValue * 4.0 as Float)
            if let hourglassCount = user.subscriptionPlan.consecutiveTrinkets?.intValue {
                hourglassCountView.amount = hourglassCount
            }
        }
    }
    
    func getUser() -> User? {
        if let sections = fetchedResultsController?.sections {
            if sections.count > 0  && sections[0].numberOfObjects > 0 {
                return fetchedResultsController?.object(at: IndexPath(item: 0, section: 0)) as? User
            }
        }
        return nil
    }
    
    func createFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        if let managedContext = managedObjectContext {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
            fetchRequest.entity = entity
            fetchRequest.fetchBatchSize = 20
            
            if let stringId = AuthenticationManager.shared.currentUserId {
                let formatString = "id == '\(stringId)'"
                fetchRequest.predicate = NSPredicate(format: formatString)
                
                let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
                let sortDescriptors = [ sortDescriptor ]
                
                fetchRequest.sortDescriptors = sortDescriptors
                
                let aFetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: fetchRequest,
                                                                                                 managedObjectContext: managedContext,
                                                                                                 sectionNameKeyPath: nil,
                                                                                                 cacheName: nil)
                aFetchedResultsController.delegate = self
                do {
                    try aFetchedResultsController.performFetch()
                } catch let error as NSError {
                    print("Unresolved error: \(error) \(error.userInfo)")
                }
                
                return aFetchedResultsController
            }
        }
        return nil
    }

}
