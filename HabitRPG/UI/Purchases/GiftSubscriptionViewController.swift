//
//  GiftSubscriptionViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.12.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
import Keys
import ReactiveSwift
import Habitica_Models

class GiftSubscriptionViewController: BaseTableViewController {
    
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var displayNameLabel: UsernameLabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var explanationTitle: UILabel!
    @IBOutlet weak var giftOneGetOneTitleLabel: UILabel!
    @IBOutlet weak var giftOneGetOneDescriptionLabel: UILabel!
    
    private let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    private let configRepository = ConfigRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    private var activePromo: HabiticaPromotion?

    var products: [SKProduct]?
    var selectedSubscriptionPlan: SKProduct?
    var isSubscribing = false
    public var giftRecipientUsername: String?
    var giftedUser: MemberProtocol? {
        didSet {
            if let user = giftedUser {
                avatarView.avatar = AvatarViewModel(avatar: user)
                displayNameLabel.text = giftedUser?.profile?.name
                displayNameLabel.contributorLevel = user.contributor?.level ?? 0
                usernameLabel.text = "@\(user.username ?? "")"
            }
        }
    }
    let appleValidator: AppleReceiptValidator
    let itunesSharedSecret = HabiticaKeys().itunesSharedSecret
    var expandedList = [Bool](repeating: false, count: 4)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        #if DEBUG
            appleValidator = AppleReceiptValidator(service: .production, sharedSecret: itunesSharedSecret)
        #else
            appleValidator = AppleReceiptValidator(service: .production, sharedSecret: itunesSharedSecret)
        #endif
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        #if DEBUG
            appleValidator = AppleReceiptValidator(service: .production, sharedSecret: itunesSharedSecret)
        #else
            appleValidator = AppleReceiptValidator(service: .production, sharedSecret: itunesSharedSecret)
        #endif
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let optionNib = UINib.init(nibName: "SubscriptionOptionView", bundle: nil)
        self.tableView.register(optionNib, forCellReuseIdentifier: "OptionCell")
        retrieveProductList()
        
        avatarView.showPet = false
        avatarView.showMount = false
        avatarView.showBackground = false
        avatarView.ignoreSleeping = true
        
        if let username = giftRecipientUsername {
            disposable.inner.add(socialRepository.retrieveMemberWithUsername(username).observeValues({ member in
                self.giftedUser = member
            }))
        }

        activePromo = configRepository.activePromotion()

        if activePromo?.identifier != "g1g1" {
            tableView.tableFooterView = nil
        } else if let footer = tableView.tableFooterView {
            footer.backgroundColor = nil
            footer.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
            let gradient: CAGradientLayer = CAGradientLayer()

            gradient.colors = [UIColor("#3BCAD7").cgColor, UIColor("#925CF3").cgColor]
            gradient.locations = [0.0, 1.0]
            gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
            gradient.frame = CGRect(x: 0.0, y: 0.0, width: footer.frame.size.width, height: footer.frame.size.height)
            footer.layer.insertSublayer(gradient, at: 0)
        }
        
        navigationController?.navigationBar.standardAppearance.shadowColor = .clear
        navigationController?.navigationBar.compactAppearance?.shadowColor = .clear
        
        explanationTitle.text = L10n.giftSubscriptionPrompt
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.giftSubscription
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.standardAppearance.backgroundColor = theme.contentBackgroundColor
        tableView.backgroundColor = theme.contentBackgroundColor
        explanationTitle.textColor = theme.primaryTextColor
        tableView.reloadData()
    }
    
    func retrieveProductList() {
        SwiftyStoreKit.retrieveProductsInfo(Set(PurchaseHandler.noRenewSubscriptionIdentifiers)) { (result) in
            self.products = Array(result.retrievedProducts)
            self.products?.sort(by: { (product1, product2) -> Bool in
                guard let firstIndex = PurchaseHandler.noRenewSubscriptionIdentifiers.firstIndex(of: product1.productIdentifier) else {
                    return false
                }
                guard let secondIndex = PurchaseHandler.noRenewSubscriptionIdentifiers.firstIndex(of: product2.productIdentifier) else {
                    return true
                }
                return firstIndex < secondIndex
            })
            self.selectedSubscriptionPlan = self.products?.first
            self.tableView.reloadData()
            self.tableView.selectRow(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .none)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let products = self.products else {
            return 0
        }

        if section == 0 {
            return products.count
        } else {
                return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 106
        }
        return 70
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section != 0 {
            return nil
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedSubscriptionPlan = (self.products?[indexPath.item])
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var returnedCell: UITableViewCell?
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as? SubscriptionOptionView else {
                fatalError()
            }
            
            let product = self.products?[indexPath.item]
            cell.priceLabel.text = product?.localizedPrice
            cell.titleLabel.text = product?.localizedTitle
            
            cell.flagView.isHidden = true
            switch product?.productIdentifier {
            case PurchaseHandler.noRenewSubscriptionIdentifiers[0]:
                cell.setMonthCount(1)
            case PurchaseHandler.noRenewSubscriptionIdentifiers[1]:
                cell.setMonthCount(3)
            case PurchaseHandler.noRenewSubscriptionIdentifiers[2]:
                cell.setMonthCount(6)
            case PurchaseHandler.noRenewSubscriptionIdentifiers[3]:
                cell.setMonthCount(12)
                cell.flagView.text = "Save 20%"
                cell.flagView.textColor = .white
                cell.flagView.isHidden = false
            default:
                break
            }
            DispatchQueue.main.async {
                cell.setSelected(product?.productIdentifier == self.selectedSubscriptionPlan?.productIdentifier, animated: true)
            }
            returnedCell = cell
        } else if indexPath.section == tableView.numberOfSections-1 {
            returnedCell = tableView.dequeueReusableCell(withIdentifier: "SubscribeButtonCell", for: indexPath)
            (returnedCell?.viewWithTag(1) as? UIButton)?.setTitle(L10n.sendGift, for: .normal)
        }
        returnedCell?.selectionStyle = .none
        return returnedCell ?? UITableViewCell()
    }
    
    func isInformationSection(_ section: Int) -> Bool {
        return section == 0
    }
    
    @IBAction func subscribeButtonPressed(_ sender: Any) {
        if isSubscribing {
            return
        }
        self.subscribeToPlan()
    }
    
    func subscribeToPlan() {
        guard let identifier = self.selectedSubscriptionPlan?.productIdentifier else {
            return
        }
        isSubscribing = true
        PurchaseHandler.shared.pendingGifts[identifier] = self.giftedUser?.id
        SwiftyStoreKit.purchaseProduct(identifier, atomically: false) { result in
            self.isSubscribing = false
            switch result {
            case .success(let product):
                self.displayConfirmationDialog()
                self.userRepository.retrieveUser().observeCompleted {}
                print("Purchase Success: \(product.productId)")
            case .error(let error):
                print("Purchase Failed: \(error)")
            }
        }
    }
    
    func isSubscription(_ identifier: String) -> Bool {
        return  PurchaseHandler.subscriptionIdentifiers.contains(identifier)
    }
    
    func isValidSubscription(_ identifier: String, receipt: ReceiptInfo) -> Bool {
        if !isSubscription(identifier) {
            return false
        }
        let purchaseResult = SwiftyStoreKit.verifySubscription(
            ofType: .autoRenewable,
            productId: identifier,
            inReceipt: receipt,
            validUntil: Date()
        )
        switch purchaseResult {
        case .purchased:
            return true
        case .expired:
            return false
        case .notPurchased:
            return false
        }
    }
    
    private func selectedDurationString() -> String {
        switch selectedSubscriptionPlan?.productIdentifier {
        case PurchaseHandler.noRenewSubscriptionIdentifiers[0]:
            return "1"
        case PurchaseHandler.noRenewSubscriptionIdentifiers[1]:
            return "3"
        case PurchaseHandler.noRenewSubscriptionIdentifiers[2]:
            return "6"
        case PurchaseHandler.noRenewSubscriptionIdentifiers[3]:
            return "12"
        default:
            return ""
        }
    }
    
    func displayConfirmationDialog() {
        var body = L10n.giftConfirmationBody(usernameLabel.text ?? "", selectedDurationString())
        if activePromo?.identifier == "g1g1" {
            body = L10n.giftConfirmationBodyG1g1(usernameLabel.text ?? "", selectedDurationString())
        }
        let alertController = HabiticaAlertController(title: L10n.giftConfirmationTitle, message: body)
        alertController.addCloseAction { _ in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                self.performSegue(withIdentifier: "unwindToList", sender: self)
            }
        }
        alertController.show()
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
