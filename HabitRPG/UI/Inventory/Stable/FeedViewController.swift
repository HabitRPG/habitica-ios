//
//  FeedViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class FeedViewController: BaseTableViewController {
    private let dataSource = FeedViewDataSource()
    var selectedFood: FoodProtocol?
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.tableView = tableView
        cancelButton.title = L10n.cancel
    }
    
    override func populateText() {
        super.populateText()
        navigationItem.title = L10n.Titles.feedPet
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedFood = dataSource.item(at: indexPath)
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 180
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = Bundle.main.loadNibNamed("ShopAdFooter", owner: self, options: nil)?.last as? UIView
        let label = view?.viewWithTag(2) as? UILabel
        label?.text = L10n.notGettingDrops
        let button = view?.viewWithTag(3) as? UIButton
        button?.borderColor = ThemeService.shared.theme.tintColor
        button?.borderWidth = 1
        button?.cornerRadius = 5
        button?.addTarget(self, action: #selector(openMarket), for: .touchUpInside)
        return view
    }
    
    @objc
    func openMarket() {
        perform(segue: StoryboardSegue.Main.showShopSegue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.showShopSegue.rawValue {
            let shopViewController = segue.destination as? ShopViewController
            shopViewController?.shopIdentifier = Constants.MarketKey
        }
    }
}
